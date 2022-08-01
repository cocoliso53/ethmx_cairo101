%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*,}():
    alloc_locals

   # Variable name inside of cairo program
    local x: felt
    %{
        # Assign input json x
        # to cairo variable x
        ids.x = program_input['x']
    %}

    # Check if the input is the square root of 25
    assert x*x = 25

    # print x
    serialize_word(x)
    return()
end
