%builtins output

from starkware.cairo.common.serialize import serialize_word

## ---  Intrucciones --- ##
## Completa el codigo para que el programa:
## Tenga tres variables: a,b y r (r ya esta)
## Usando un input (json) asigna el valor de a y b
## defina el valor de r como la multiplicacion de
## a con b, y ademas que su valor sea 60
## por ultimo, crea un archivo input.json
## que funcione al correr el programa

func main{output_ptr : felt*,}():

    alloc_locals

    # Crea dos variables locales
    # llamdas a y b de tipo felt
    
    # Completa la linea para crear a
    local a: felt

    # Completa la linea para crear b
    local b: felt
    
    # Definimos tambien r
    local r: felt

    # Ahora viene el hint
    # aqui se asignan los valores 
    # de a y b que se leen del input
    # input es un archivo json

    %{
        # Asigna los valores de a y b
        # recuerda que se usa ids
        # para referirse a las vairbles de cairo
        
        ids.a = program_input['a']
        ids.b = program_input['b']

    %}

    # Doble funcion de assert

    # Usa assert para que r sea
    # la multiplicacion de a y b
    assert r =  a*b


    # Ahora usa asser para validar que
    # que r es 60
    assert r = 60

    # imprime a
    serialize_word(a)
    
    # imprime b
    serialize_word(b)

    return()
end

## El archivo json tiene la forma
## {"a": 3, "b": 20}
