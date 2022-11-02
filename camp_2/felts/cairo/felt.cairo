// En el contexto de El Cairo, cuando decimos "un elemento de campo" nos referimos a un número entero 
// en el rango -P/2 < x P/2
%builtins output

from starkware.cairo.common.serialize import serialize_word

const FELT_SIZE = 2**251 + 17 * 2**192 + 1;

// cairo-compile felt.cairo --output felt_compiled.json
// cairo-run --program felt_compiled.json --print_output --layout=small
func main{output_ptr : felt*}(){
    // FELT_SIZE operations
    serialize_word(FELT_SIZE); // will be 0
    serialize_word(FELT_SIZE/2 + 1); // will be 0
    serialize_word(FELT_SIZE/2 - 1); // will be 0
    serialize_word(FELT_SIZE - 1); // will be -1
    serialize_word(FELT_SIZE + 1); // will be +1

    // FELT Division
    serialize_word(6 / 3); // will be 2
    serialize_word(7 / 3); // will be 1206167596222043737899107594365023368541035738443865566657697352045290673496

    let res = 7 / 3;
    serialize_word(res * 3); // will be 7

    return ();
}
