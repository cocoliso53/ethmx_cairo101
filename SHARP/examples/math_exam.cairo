%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():

    alloc_locals

    # Variable que contiene la respuesta
    local x: felt

    # Numero de lista del alumno
    local list_num: felt

    %{
        # Toma el input del alumno
        # x es la respuesta al problema
        ids.x = program_input['x']
        
        # indica tambien su numero de lista
        ids.list_num = program_input['list_num']
        
    %}

    # Checa si x resulve la ecuacion
    assert x*x - 12*x + 35 = 0

    # Ahora devuelve el numero de lista del alumno
    # Asi podemos verificar para cada alumno
    # si paso o no el examen sin ver sus respuestas
    serialize_word(list_num)
    return()
end
