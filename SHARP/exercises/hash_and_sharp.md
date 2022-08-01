# Ejercicios 

Para esta parte vamos a jugar un poco con la solución 
del ejercicio anterior que escribiste

## Hashes del programa

Primero que nada calcula el hash del programa que escribiste en el 
ejercicio anterior usando el comando `cairo-hash-program --program=NOMBRE_PROGRAMA.json`.

Nota que el programa que se pasa de argumento es un `json` lo cual quiere decir que 
lo tienes que compilar primero.

Toma nota del hash para que no se te olvide

### Cambiando el hint

Ahora hagamos una pequeña modificación en el hint. Verifiquemos ahí
mismo que el la multiplicación de `a` y `b` es 60. Para ello simplemente 
se agrega una línea 
``` cairo
%{
    # Codigo anterior
    ids.a = program_input['a']
    ids.b = program_input['b']

    # Agrega esta linea
    assert a*b == 60
%}
```

Ahora: 
- Guarda los cambios
- Compila de nuevo el programa
- Calcula nuevamente el hash

¿Qué notas? 


### Cambiando el código en Cairo

En el programa tal cual lo tenemos ahora estamos checando dos veces 
que `a` por `b` sea 60 (en el hint y afuera de el). 

Vamos a hacer otra prueba sencilla y ahora vamos a borrar la linea
`assert r = 60` en el código de cairo. 

Una vez más haz lo siguiente: 
- Guarda los cambios
- Compila de nuevo el programa
- Calcula nuevamente el hash

¿Qué notas de diferente con respecto a la vez pasada?
¿Qué afecta y qué no afecta el hash del programa? 

## SHARP

Volvamos a usar el código como lo teníamos antes del ejercicio anterior (con el `assert` en el codigo de
cairo pero no en el hint). 

Con un archivo `json` con el cual el programa se ejecute correctamente corre el siguiente comando

``` cairo
cairo-sharp submit --source NOMBRE_PROGRAMA.cairo --program_input input.json
```

Toma nota del `Job key` y del `Fact`, el `Job key` nos sirve para ver el progreso de "subir"
nuestro fact a SHARP. Lo podemos hacer de la siguiente manera:

```cairo-sharp status JOB-KEY```

Después de unos minutos ingresa a [esta liga](https://goerli.etherscan.io/address/0xAB43bA48c9edF4C2C4bB01237348D1D7B28ef168#readProxyContract),
copia el `Fact` que te salió en el paso anterior y pégalo en `5. isValid` en el link anterior. Observa el resultado. 

## Facts

Vamos a cambiar un poco de ambiente para usar python con la librería web3. Copia el código que está en el archivo `fact_calculator.py` y 
asegurate de tener a la mano el hash del programa con el cual usaste SHARP y los dos números de tu archivo `input.json`

Ahora has los siguientes cambios en el código: 
``` python
from web3 import Web3

#  Ingresa aquí el hash de tu programa como numero hexadecimal
program_hash = HASH_PROGRAMA 
# Ingresa a esta lista los inputs de tu programa
# Ejemplo, si tu json es {"a": 3, "b": 20}
# entonces la lista seria [3, 20]
# Nota que el orden importa
program_output = [INPUT_a, INPUT_b]

output_hash = Web3.solidityKeccak(['uint256[]'], [program_output])
fact = Web3.solidityKeccak(['uint256', 'bytes32'],[program_hash, output_hash])

print(fact.hex())

```

Salva el código y córrelo con el comando `python3 fact_calculator.py`

Después de correr el programa el `fact` resultante debería de ser el mismo que obtuviste 
al momento de usar SHARP. 

Prueba ahora lo siguiente: 
- Cambia de orden los elementos de la lista y calcula el `fact`
- Coloca valores distintos que no cumplan la regla del programa
- Intenta verificar la validez de ese nuevo `fact` [aqui](https://goerli.etherscan.io/address/0xAB43bA48c9edF4C2C4bB01237348D1D7B28ef168#readProxyContract)




