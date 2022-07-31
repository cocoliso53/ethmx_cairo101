# SHARP 101

## Raiz Cuadrada de 25

``` cairo
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():
    alloc_locals

   # Variable name inside of cairo program
    local x: felt
    %{
        # Assign input json input x
        # to cairo variable x
        ids.x = program_input['x']
    %}

    # Check if the input is the square root of 25
    assert x*x = 25

    # print x
    serialize_word(x)
    return()
end
```

Toma un input de un archivo `json` que contiene una variable de nombre `x`, por ejemplo
el archivo `json` puede ser simplemente `{"x": 5}`

Notemos que tanto la varible en `cairo` y en el input tienen el mismo nombre.
Esto no es necesario, por ejemplo podemos cambiar el hint de esta manera: 

``` cairo
%{
        ids.x = program_input['x_input']
%}
```

Entonces nuestro archivo `json` con el input debería de cambiar a `{"x_input": 5}`.

### Verificando que el programa funciona

Si el código anterior lo guardamos en un archivo `sqrt25.cairo` lo compilamos así
```cairo-compile sqrt25.cairo --output sqrt25.json```

Creamos un archivo `input.json` que simplemente contenga `{"x": 5}` y corremos el programa
```cairo-run --program=sqrt25.json --print_output --layout=small --program_input=input.json```

Deberíamos de ver en la pantalla algo como esto
```
Program output:
5
```

Veamos ahora que pasa si modificamos `input.json` a `{"x": 3}` e intentamos correr el programa
de nuevo

```
An ASSERT_EQ instruction failed: 25 != 9.
    assert x*x = 25
    ^*************^
```

El programa falló lo cual es bueno ya que confirma que funciona como esperábamos (dado que 3 no es
raíz cuadrada de 25)


## Usando SHARP (Shared Prover)

### Hash del programa

Podemos pensar el hash como un ID único para cada programa.

El programa que acabamos de escribir tiene un hash que se puede obtener con el comando
```cairo-hash-program --program=sqrt25.json```

Deberíamos obtener `0x39c4ead4bce418310a6df15cdaa331fc27d07ec813dc4d73c3dc14def32649b`

### Enviando el programa y la prueba a SHARP
SHARP (Shared Prover) es un servicio que genera pruebas que aseguran la valides de la ejecución 
de los programas escritos en cairo y que además manda esas prueba a una testnet de Ethereum (Goerli)
donde pueden ser verificados por un smart contract. (Refinar esto)

Para "subir" nuestro resultado de la ejecución de `sqrt25` on-chain hacemos en la terminal:

`cairo-sharp submit --source sqrt25.cairo --program_input input.json`

En la terminal veríamos algo parecido a esto: 
```
Compiling...
Running...
Submitting to SHARP...
Job sent.
Job key: 59896d17-19c6-4e77-ba19-4f703156f218
Fact: 0x4d3420edf3a438ee8dc29fc5c86297791b31aaf2480d8fa9cf54279122e65bf
```

`Job key` nos sirve para monitorear si es que la prueba ya está disponible en Ethereum corriendo el comando
```cairo-sharp status 59896d17-19c6-4e77-ba19-4f703156f218```

### #FACTS
`Fact` es el resultado de hashear el hash del programa (`0x39c4ead4bce418310a6df15cdaa331fc27d07ec813dc4d73c3dc14def32649b` 
en este caso) y el `output` que este mismo produce (en este ejemplo es `5`)

El fact lo podemos calcular con el siguiente código de python

``` python
from web3 import Web3
# Substitute for adecuate values
# Notice this is not a string
program_hash = 0x39c4ead4bce418310a6df15cdaa331fc27d07ec813dc4d73c3dc14def32649b
# If multiple outputs just add elements to the list
program_output = [5]

output_hash = Web3.solidityKeccak(['uint256[]'], [program_output])
fact = Web3.solidityKeccak(['uint256', 'bytes32'],[program_hash, output_hash])

# Result will be 0x4d3420edf3a438ee8dc29fc5c86297791b31aaf2480d8fa9cf54279122e65bf
```

Ya que el resultado esté disponilbe en Goerli lo podemos verificar 
[aqui](https://goerli.etherscan.io/address/0xAB43bA48c9edF4C2C4bB01237348D1D7B28ef168#readProxyContract).

Noten que lo requerido para calcular el `Fact` es el output, no el input. En este caso coinciden pero 
veamos un ejemplo en donde no sea así.


## Examen de álgebra
El siguente programa sirve para verificar las raices de un polinomio `x*x - 12*x + 35`,
el input tiene que ser un `x` tal que al momento de sustituir en la ecuación anterior el
resultado sea 0. 

``` cairo
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():
    alloc_locals

    # Variable in Cairo
    local x: felt

    %{
        # Takes user input
        ids.x = program_input['x']
    %}

    # Checks input is a solution for x
    assert x*x - 12*x + 35 = 0

    serialize_word(x)
    return()
end
```

Supongamos que queremos aplicar un examen para ver qué estiduantes saben alguna de las dos respuestas correctas.
Lo que cada estudiante tendría que hacer es lo siguiente: 
- Copiar el programa en un archivo `.cairo` 
- Crear `input.json` donde esté su respuesta en formato `json`
- Usar `cairo-sharp` para generar la prueba en Goerli
- Que nos hagan llegar a nosotros (el maestro) el hash del `Fact` junto con el `output` que produce el programa
- Nosotros revisamos la validez del `Fact` que debe de estar ya on-chain

### Ocultando información

Si utilizáramos el código anterior como el examen tal cual entonces tendríamos un par de problemas: 
- No hay manera de asignar un `Fact` para cada alumno
- En el `output` está la respuesta y es lo que queremos mantener oculto

Así que vamos a hacer un par de modificaciones sencillas, para esto vamos a suponer que a cada alumno
le corresponde un número de lista distinto. Entonces nuestro programa `examen.cairo` quedaría así:

``` cairo
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():
    alloc_locals

    # Variable in Cairo
    local x: felt

    # New felt for alumn's list number
    local list_num: felt

    %{
        # Takes user input
        ids.x = program_input['x']
        # List number is taken from the input file
        ids.list_num = program_input['list_num']
        
    %}

    # Checks input is a solution for x
    assert x*x - 12*x + 35 = 0

    # Now we return the alumn's list number instead of the result
    serialize_word(list_num)
    return()
end
```

Vamos a ver qué cambios se hicieron: 
1. Se añade la variable local `list_num` en cairo
2. A esa variable se le asigna un valor dentro del hint que viene del `input.json`
3. El output del programa es el valor de `list_num`

Lo que ganamos con esto es que vamos a obtener un `Fact` por cada alumno que pueda dar
un input correcto que cumpla la condición sin revelar qué valor para `x` fue el que ingresó, 
lo único que vamos a tener por seguro es que el programa se ejecutó correctamente.

Vamos a compilar el programa
`cairo-compile examen.cairo --output examen.json`

Y calculemos ahora su hash

```
cairo-hash-program --program=examen.json
0x6d05ac3baea03c9af7a6358e92485a83f92d7d1e4addf22a7fccf64bd3ead30
```

Una de las dos soluciones que logra correr el programa satisfactoriamente es
`x = 5`, supongamos que el alumno con número de lista es `9` crea `input.json` así:
`{"x": 5, "list_num": 9}`.

Este alumno correría el programa para verificar que funciona

```
cairo-run --program=examen.json --print_output --layout=small --program_input=input.json
Program output:
9
```

Ya que eso funcionó entonces lo siguiente sería que dejara constancia on-chain de su prueba resuelta, 
o mejor dicho, de que los inputs que dió hicieron que el programa se ejecutara de manera correcta.
Para esto se hace uso de SHARP nuevamente:

```
cairo-sharp submit --source examen.cairo --program_input input.json
Compiling...
Running...
Submitting to SHARP...
Job sent.
Job key: b96185be-495b-460a-b606-d4709d921267
Fact: 0x3cd1ef77ae489c5eae30bef10960bbfb61712bf14c03c9dadef481a077f90c16
```
Cuando el alumno nos notifique que ya resolvió el examen y que "subió" el resultado a SHARP, lo 
único que tenemos que hacer nosotros como profesores es tomar su número de lista y el hash del 
programa para calcular el hash del `Fact`. Ya que lo obtenemos podemos verificar on-chain si aprovó 
o no el examen.

Notemos que no es necesario saber que valor de `x` utilizó, simplemente su número de lista.

### Evitando fraude

Con este "examen" solo necesitamos saber los números de lista de cada estudiante para verificar si
lograron o no aprobar el examen. ¿Qué pasa si uno de ellos intenta hacer trampa modificando el programa? 

Alguno de los estudiantes, sabiendo que el programa en cairo solo tiene como output su número de lista, puede
intentar modificar el programa de la siguiente manera: 

``` cairo
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():
    alloc_locals

    # Variable in Cairo
    local x: felt

    # New felt for alumn's list number
    local list_num: felt

    %{
        # Takes user input
        ids.x = program_input['x']
        # List number is taken from the input file
        ids.list_num = program_input['list_num']
        
    %}

    # No assertion

    # Just return the alumn's list number
    # Nothing is actually chekced for
    serialize_word(list_num)
    return()
end
```

Con esta pequeña modificación el programa ya no revisa si el input `x` es solución
para la fórmula que queríamos verificar, sin embargo sí va a devolver su número de lista. 

Más aún, cualquier input va a ser valido ya que el programa en cairo no revisa nada, simplemente imprime
lo que sea que se ponga en `list_num`, su ejecución siempre será correcta. 
Supongamos que su `input.json` es `{"x": 1, "list_num": 13}`

Entonces el engaño se haría así: 
- Compilar el nuevo programa modificado del examen
- Usar su `input.json` con su número de lista 
- Empujar el resultado a SHARP
- Darnos el hash del `Fact` para que lo comprobemos on chain

Después de hacer todos esos pasos el `Fact` que resulta es `0x2dad3645cb0ccf32db221f62a8cd914ced2ba0e09ec83dc7416e6b3e22f35aa0`, 
esto lo pueden verificar ustedes mismos, solo recuerden usar la versión modificada del examen y que
el número de lista que se imprima sea 13. 

Si nosotros como profesores checaramos solamente el hash del `Fact` on-chain veríamos que, en efecto, es verdadero.
¿Por qué? porque el programa que se ejecutó para generar esa prueba se ejecutó de manera válida, el problema es que 
no es el programa que nosotros queríamos que los estudiantes ejecutaran. 

¿Cómo nos podríamos dar cuenta del engaño? 
Dado que nosotros conocemos el programa que escribirmos y su hash
(que para recordar es `0x6d05ac3baea03c9af7a6358e92485a83f92d7d1e4addf22a7fccf64bd3ead30`)
además del número de lista de todos los estudiantes, entonces podemos verificar si el `Fact`
que nos pasó #13 fue generado con nuestro programa. Recuerden, el `Fact` depende del hash del programa que se ejecuta
y del output que este genera. 

Ahora usamos el script de python para calcular facts
``` python
from web3 import Web3
# Substitute for adecuate values
program_hash = 0x6d05ac3baea03c9af7a6358e92485a83f92d7d1e4addf22a7fccf64bd3ead30
# If multiple outputs just add elements to the list
program_output = [13]

output_hash = Web3.solidityKeccak(['uint256[]'], [program_output])
fact = Web3.solidityKeccak(['uint256', 'bytes32'],[program_hash, output_hash])
# fact is 0x49eedf269ac57e717dc9dca4c6568450f11101246ed2c51bc1d58ff642ae1aa9
```
Nos damos cuenta que el fact para nuestro programa que tiene como output `13` debería de ser 
`0x49eedf269ac57e717dc9dca4c6568450f11101246ed2c51bc1d58ff642ae1aa9` pero el que nos dió el estudiante fue
`0x2dad3645cb0ccf32db221f62a8cd914ced2ba0e09ec83dc7416e6b3e22f35aa0` |:<

Ahora sabemos que casi fuimos embaucados pero tuvimos manera de verificarlo ;)