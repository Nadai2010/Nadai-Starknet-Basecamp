// builtins = Unidades de ejecución de bajo nivel optimizadas predefinidas agregadas a la CPU de Cairo 
// - Cuando pasamos el indicador de 'diseño', especificamos qué elementos integrados y cuántas 
//   instancias se pueden usar.
// - Requiere que main tome un argumento y debe devolver el valor después de escribir especificando 
//   donde esta.

%builtins output

// cairo-compile builtins.cairo --output builtins_compiled.json
// cairo-run --program builtins_compiled.json --print_output --layout=small

// Run w/ Debug Info:
// cairo-run --program builtins_compiled.json --print_memory --print_info --trace_file=builtins_trace.bin --memory_file=ap_memory.bin --relocate_prints --layout=small

func main(output_ptr: felt*) -> (output_ptr: felt*) {
    // Asigne 100 a la primera celda de memoria no utilizada y avance ap.
    [ap] = 100;
    [ap] = [output_ptr], ap++;

    [ap] = 200;
    [ap] = [output_ptr + 1], ap++;

    [ap] = 300;
    [ap] = [output_ptr + 2], ap++;

    // Devolver el mismo valor de la output_ptr
    // que fue adelantado por 3
    [ap] = output_ptr + 3, ap++;
    ret;
}