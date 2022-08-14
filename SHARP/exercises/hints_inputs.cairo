%builtins output

from starkware.cairo.common.serialize import serialize_word

## ---  Intrucciones --- ##
## Completa el codigo para que el programa:
##
## 1) Tenga tres variables: a,b y r (r ya esta)
##
## 2) Usando un input (json) asigna el valor de a y b
## 
## 3) Defina el valor de r como la multiplicacion de
## a con b, y ademas que su valor sea 60
## 
## Despues:
## 
## Compila el programa
##
## Crea un archivo input.json 
## que funcione al correr el programa
##
## Corre el programa y verifica que salga bien
##
##  Para ompilar:
## cairo-compile PROGRAMA.cairo --output PROGRAMA.json
## (cambia PROGRAMA por el nombre que quieras)
##
## Para correr programa: 
## cairo-run --program=PROGRAMA.json --print_output --layout=small --program_input=input.json


func main{output_ptr : felt*,}():

    alloc_locals
    
    # Definimos r
    local r: felt

    # Crea dos variables locales
    # llamdas a y b de tipo felt
    
    # Completa la linea para crear a
    local 

    # Completa la linea para crear b
    local
    

    # Ahora viene el hint
    # aqui se asignan los valores 
    # de a y b que se leen del input
    # input es un archivo json

    %{
        # Asigna los valores de a y b
        # recuerda que se usa ids
        # para referirse a las vairbles de cairo


    %}

    # Doble funcion de assert

    # Usa assert para que r sea
    # la multiplicacion de a y b
    assert r = 


    # Ahora usa assert para validar
    # que r es 60
    assert r = 

    # imprime a
    serialize_word(a)
    
    # imprime b
    serialize_word(b)

    return()
end

