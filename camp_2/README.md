<div align="center">
    <h1>Camp 2: Cairo</h1>

|Presentation|Video|Workshop
|:----:|:----:|:----:|
|[Cairo](https://drive.google.com/file/d/1nXi1ZLPM-19kXpCxwOMLQU_GMzlNYMNZ/view?usp=sharing)|[Cairo Basecamp](https://drive.google.com/file/d/1w9ysR38Dz4Z9gvHC46xSHbr06B36nUWp/view?usp=sharing)|[StarkNet Cairo 101](https://github.com/starknet-edu/starknet-cairo-101)|

</div>

### Topics

<ol>
    <li>CLI</li>
    <li>C(pu)AIR(o)</li>
    <li>Syntax</li>
    <li>Cairo VM</li>
</ol>

<div align="center">
    <h2 id="cairo_cli">CLI Cheatsheet</h2>
</div>

```bash
# compile cairo program
cairo-compile example.cairo --output example_compiled.json

# run cairo program and output results
cairo-run --program=example_compiled.json --print_output --layout=small

# output the KECCAK Fact of the cairo program
cairo-hash-program --program=example_compiled.json

# format/lint your cairo program
cairo-format -i example.cairo

# compile cairo program and submit the fact to the SHARP
cairo-sharp submit --source example.cairo --program_input input.json
```

<h2 align="center" id="cairolang">C(pu)AIR(o)</h2>

Como vimos en [Camp 1](../camp_1), el sistema de prueba STARK se basa en `AIR` o representación intermedia algebraica de cálculo. El AIR es una lista de restricciones polinómicas que operan en un rastro de elementos de campo finito y la Prueba STARK verifica que existe un rastro que satisface esas restricciones.

Cairo significa CPU AIR y consta de un único conjunto de restricciones polinómicas de modo que la ejecución de un programa en esta arquitectura es válida. Cairo es un lenguaje de programación para escribir programas demostrables.

***Una arquitectura de CPU compatible con STARK completa y prácticamente eficiente de Turing***

`Práctico`: Cairo admite ramas condicionales, memoria, llamadas a funciones y recursividad

`Eficiente`: ​​Conjunto de instrucciones elegido para que el AIR correspondiente sea eficiente y optimizado con `incorporados`

`Turing Complete`: puede simular cualquier máquina de Turing, ya que admite cualquier cálculo factible

`EN CONSTRUCCIÓN`:

Mientras se crea esta sección, recomendamos leer la sesión de video de este campamento y los [documentos de cairo-lang](https://www.cairo-lang.org/docs/how_cairo_works/index.html).
<hr>

<h2 align="center" id="computational_integrity">Computational Integrity</h2>
STARKs

<h2 align="center" id="syntax">Syntax</h2>

<h3>FELTs</h3>

`EN CONSTRUCCIÓN`

En la mayor parte de su código (a menos que tenga la intención de escribir código muy algebraico), no tendrá que lidiar con el hecho de que los valores en Cairo son fieltros y puede tratarlos como si fueran números enteros normales ([documentación de Cairo](https://www.cairo-lang.org/docs/hello_cairo/intro.html#the-primitive-type-field-element-felt)). El elemento de campo `felt` es el único tipo de dato que existe en Cairo, incluso puedes omitir su declaración explícita; cuando no se especifica el tipo de una variable o argumento, automáticamente se le asigna el tipo sentido. Las direcciones también se almacenan como fieltros.

Un fieltro puede ser negativo o cero, y puede ser un número entero grande: específicamente, puede estar en el rango $-X < fieltro < X$, donde $X = (2^{251} + 17) * (2^{ 192} + 1)$ . Cualquier valor que no esté dentro de su rango provocará un “desbordamiento”: un error que ocurre cuando un programa, Cairo, recibe un número o valor fuera del alcance de su capacidad de manejo. Así, cuando sumamos, restamos o multiplicamos y el resultado está fuera del rango del fieltro, hay un desbordamiento.

Compila y ejecuta [felt.cairo](./felts/cairo/felt.cairo) con:

```bash
cairo-compile felts/cairo/felt.cairo --output felt_compiled.json
cairo-run --program felt_compiled.json --print_output --layout=small
```

Tu Conseguirás:   

```bash
Program output:
  0
  -1
  1
  2
  1206167596222043737899107594365023368541035738443865566657697352045290673496
  7
```

`FELT_SIZE = 2**251 + 17 * 2**192 + 1` está justo fuera del rango de valores que puede tomar un felt, entonces se desbordará a `0` como se evidencia al ejecutar `serialize_word(FELT_SIZE)`.

La diferencia más importante entre enteros y elementos de campo es la división: la división de fieltros no es la división de enteros en muchos lenguajes de programación; se devuelve la parte integral del cociente (así que obtienes $(7/3 = 2)$. Siempre que el numerador sea un múltiplo del denominador, se comportará como esperas $(6/3 = 2)$. Si este no es el caso, por ejemplo cuando dividimos $7/3$, resultará en un sentido $x$ que satisface $(3 * x = 7)$; específicamente, $x=12061675962220437378991075943650233685410357384438655566657697352045290673496$. sea $2.3333$ porque $x$ tiene que ser un número entero y dado que $3 * x$ es mayor que $2**251 + 17 * 2**192 + 1$ se desbordará a exactamente $7$. En otras palabras, cuando estemos usando aritmética modular, a menos que el denominador sea cero, siempre habrá un número entero $x$ que satisfaga $denominador * x = numerador$.


<h3>El conjunto de instrucciones de El Cairo (Algebraic RISC)</h3>

Aquí hay un buen modelo mental de [@liamzebedee](https://twitter.com/liamzebedee/status/1516298353080152064) para pensar en El Cairo:

* AIR = Montaje para STARK's
* Idioma Cairo = Java para STARK

El código Java se convierte en código de bytes JVM que se interpreta en ensamblador; De manera similar, el código de Cairo (el idioma) se interpreta en el código de bytes de CairoVM, que se interpreta en AIR. La JVM se ejecuta en un procesador x86 (p. ej., java.exe) y la CairoVM se ejecuta en un probador STARK. Los probadores STARK finalmente se integrarán en el hardware, al igual que otros coprocesadores criptográficos (TPM, enclaves).

A diferencia de los conjuntos de instrucciones ordinarios, que se ejecutan en un chip físico construido con transistores, Cairo se ejecuta en un AIR (el seguimiento de la ejecución se verifica mediante un AIR). En términos generales, la restricción más importante al diseñar un AIR (y, por lo tanto, al diseñar un conjunto de instrucciones que será ejecutado por un AIR) es minimizar la cantidad de celdas de seguimiento utilizadas.

El conjunto de instrucciones es el conjunto de operaciones que la CPU de Cairo puede realizar en un solo paso. Cairo utiliza un conjunto de instrucciones pequeño y simple, pero relativamente expresivo; se eligió para que el AIR correspondiente sea lo más eficiente posible. Es un equilibrio entre:
1. Un conjunto mínimo de instrucciones simples que requieren una cantidad muy pequeña de celdas de rastreo; y
2. Instrucciones lo suficientemente poderosas que reducirán la cantidad de pasos requeridos.

Particularmente:

1. Se admiten sumas y multiplicaciones.
2. Se admite verificar si dos valores son iguales, pero no hay instrucciones para verificar si un determinado valor es menor que otro valor (dicha instrucción habría requerido muchas más celdas de seguimiento ya que un campo finito no admite un campo lineal algebraico), ordenación de sus elementos.

Este conjunto minimalista de instrucciones se denomina RISC algebraico (computadora con conjunto de instrucciones reducido); "Algebraico" se refiere al hecho de que las operaciones admitidas son operaciones de campo. El uso de un RISC algebraico nos permite construir un AIR para El Cairo con solo 51 celdas de seguimiento por paso.


<h3>Builtins</h3>

El RISC algebraico puede simular cualquier máquina de Turing y, por lo tanto, es Turing-completo (admite cualquier cálculo factible). Sin embargo, implementar algunas operaciones básicas, como la comparación de elementos, usando solo las instrucciones de Cairo daría como resultado una gran cantidad de pasos que dañan el objetivo de minimizar la cantidad de celdas de rastreo utilizadas. Considere que agregar una nueva instrucción al conjunto de instrucciones tiene un costo, incluso si esta instrucción no se utiliza. Para mitigar esto sin aumentar el número de celdas de seguimiento por instrucción, Cairo introduce la noción de funciones integradas.

> Los componentes integrados son unidades de ejecución de bajo nivel optimizadas predefinidas que se agregan a la placa de la CPU de Cairo para realizar cálculos predefinidos que son costosos de realizar en el Cairo estándar (por ejemplo, comprobaciones de rango, hash de Pedersen, ECDSA, …).

La comunicación entre la CPU y las funciones integradas se realiza a través de la memoria: a cada función integrada se le asigna un área continua en la memoria y se aplican algunas restricciones (según la definición de la función integrada) en las celdas de memoria de esa área. En términos de compilación de AIR, significa que agregar funciones integradas no afecta las restricciones de la CPU. Simplemente significa que la misma memoria se comparte entre la CPU y los componentes integrados. Para “invocar” una función interna, el programa Cairo se “comunica” con ciertas celdas de memoria, y la función interna impone algunas restricciones en esas celdas de memoria.

Por ejemplo, el comando interno `range-check` impone que todos los valores de las celdas de memoria en algún rango de direcciones fijo estén dentro del rango $[0, 2^{128})$. Las celdas de memoria restringidas por el comando `range-check` se denominan celdas "range-checked".

En términos prácticos, una función integrada se utiliza escribiendo (y leyendo) las entradas en un segmento de memoria dedicado al que se accede a través del "puntero integrado": cada función integrada tiene su puntero para acceder al segmento de memoria de la función integrada. Los punteros integrados siguen la convención de nombres `<builtin name>_ptr`; por ejemplo, `range_check_ptr`. En el caso de El Cairo, la directiva incorporada agrega los punteros incorporados como parámetros a main, que luego se pueden pasar a cualquier función que los utilice. Las declaraciones incorporadas aparecen en la parte superior del archivo de código Cairo. Se declaran con la directiva `%builtins`, seguida del nombre de los buildins; por ejemplo, `%builtin range_check`. En los contratos StarkNet no es necesario agregarlos.

Los punteros incorporados pueden ser de diferentes tipos. La siguiente tabla resume los componentes disponibles, para qué sirven, sus nombres de puntero y sus tipos de puntero.

| **Builtin** | For...                                                                                           | **Pointer name** |   **Pointer type**   |
|:-----------:|--------------------------------------------------------------------------------------------------|:----------------:|:--------------------:|
| output      | Escribir la salida del programa que aparece explícitamente en una prueba de ejecución                             | output_ptr       | felt*                |
| pedersen    | Cálculo del hash de funcion de Pedersen                                                 | pedersen_ptr     | HashBuiltin*         |
| range_check | Comprobación de que un elemento de campo está dentro de un rango $[0,2^{128})$, y para hacer varias comparaciones | range_check_ptr  | felt (not a pointer) |
| ecdsa       | Verifying ECDSA signatures                                                                       | ecdsa_ptr        | SignatureBuiltin*    |
| bitwise     | Realización de operaciones bit a bit en felts                                                           | bitwise_ptr      | BitwiseBuiltin*      |

Los detalles de cada tipo se encuentran en la [biblioteca común](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo). Cada tipo, que no es directamente un `felt*`, no es más que una estructura. Por ejemplo, [`HashBuiltin`](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo#L5):

```Rust
struct HashBuiltin {
    x: felt,
    y: felt,
    result: felt,
}
```

Nota la siguiente implementación de la [función hash2](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/hash.cairo) para calcular el hash de dos elementos de campo:

```Rust
from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2(hash_ptr: HashBuiltin*, x, y) -> (
    hash_ptr: HashBuiltin*, z: felt
) {
    let hash = hash_ptr;
    // Invoca la función hash.
    hash.x = x;
    hash.y = y;
    // Devuelve el puntero actualizado (aumentado en 3 celdas de memoria)
     // y el resultado del hash.
    return (hash_ptr=hash_ptr + HashBuiltin.SIZE, z=hash.result);
}
```

`hash_ptr` se agregó como un argumento explícito y se devolvió explícitamente actualizado (`hash_ptr + HashBuiltin.SIZE`). Tenemos que realizar un seguimiento de un puntero a la siguiente celda de memoria incorporada no utilizada. La convención es que las funciones que usan el incorporado deben obtener ese puntero como argumento y devolver un puntero actualizado a la siguiente celda de memoria incorporada no utilizada.

Es más fácil usar argumentos implícitos: un azúcar sintáctico de Cairo que devuelve automáticamente el argumento implícito. La implementación de biblioteca común de la [función hash2](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/hash.cairo) es:

```Rust
%builtins pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2{hash_ptr: HashBuiltin*}(x, y) -> (result: felt) {
    // IInvoca la función hash
    hash_ptr.x = x;
    hash_ptr.y = y;
    let result = hash_ptr.result;
    // Actualizar hash_ptr (aumentado por 3 celdas de memoria)
    let hash_ptr = hash_ptr + HashBuiltin.SIZE;
    return (result=result);
}
```

`hash_ptr` se actualiza pero esta vez se devolvió implícitamente. Como otro ejemplo, esta es la implementación de la [función serialize_word](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/serialize.cairo#L1) que generará un felt en su terminal:

```Rust
func serialize_word{output_ptr: felt*}(word) {
    // Invocar la función de salida
    assert [output_ptr] = word;
    // Actualizar output_ptr (aumentado en 1 celda de memoria)
    let output_ptr = output_ptr + 1;
    return ();
}
```

Consulte la implementación en [builtins/cairo/hash.cairo](./builtins/cairo/hash.cairo) para ver un ejemplo del uso de las funciones integradas `output`, `pedersen` y `range_check`.

¿En qué momento las funciones `hash2` y `serialize_word` invocaron las propiedades de sus componentes integrados?

1. Cuando llamamos a `%builtins output pedersen` al comienzo del programa Cairo, la máquina virtual Cairo se prepara para usar los punteros `output_ptr` y `pedersen_ptr`, y sus respectivos segmentos de memoria: generalmente 2 y 3 (el segmento 1 es comúnmente el segmento de ejecución, más en la siguiente sección).

2. En segundo lugar, el código Cairo lee o escribe en las celdas de memoria en los segmentos asignados a `output` y `pedersen`.

3. Finalmente, cuando se escribe un valor en una celda de memoria dentro de un segmento integrado, se invocan las propiedades integradas. Por ejemplo, cuando se define un `struct HashBuiltin` (hay que indicar `x` e `y`, ver la estructura de [`HashBuiltin`](https://github.com/starkware-libs/cairo-lang/ blob/master/src/starkware/cairo/common/cairo_builtins.cairo#L5) entonces el incorporado de Pedersen hace cumplir ese $resultado == hash(x, y)$. Entonces podemos recuperar el valor de `result` con `let result = hash_ptr.result;` como en la función `hash2`. Cada vez que el programa desee comunicar información al verificador, puede hacerlo escribiéndola en un segmento de memoria designado al que se puede acceder mediante el uso de `output` incorporado (ver más en [los documentos](https://starknet.io/docs/how_cairo_works/program_input_and_output.html#id2)).


<h3>Memoria y segmentos</h3>

**Continuo**. Las direcciones de memoria a las que accede un programa deben ser continuas. Por ejemplo, si se accede a las direcciones 7 y 9, también se debe acceder a la 8 antes de que finalice el programa. El comprobador llenará automáticamente las celdas de memoria vacías con valores arbitrarios. Tener tales brechas es ineficiente, ya que significa que la memoria se consume sin usarse. Introducir demasiados agujeros podría encarecer demasiado la generación de una prueba. Sin embargo, esto aún no viola la garantía de solidez: no se puede generar una prueba falsa de todos modos. En la práctica, podemos almacenar valores en celdas de memoria mientras saltamos celdas de memoria (ver [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo)), el probador llenará las celdas vacías para mantener la memoria continua.

**Escritura una vez, solo lectura**. Podemos pensar en la memoria de El Cairo como una memoria de una sola escritura (solo se puede escribir una vez). Si asignamos que `assert [d] = 7;` entonces la dirección `d` en memoria siempre contendrá el valor `7` hasta que finalice la ejecución de nuestro programa. No podremos cambiar qué dirección almacena `d` en tiempo de ejecución, solo podemos escribirla una vez y luego leerla.

**Direcciones relativas**. La dirección absoluta de cada celda de memoria solo se puede determinar al final de la ejecución del programa Cairo. Es decir, estamos tratando con direcciones relativas a otras direcciones. No puedo decir que quiero que el fieltro equivalente a `“I rule here”` se encuentre en la celda de memoria número 32. Puedo decir, por ejemplo, quiero que el felt equivalente a `"Cairo rule”` se encuentre en celda vacía o en tres celdas de la actual que se está utilizando. ¿Te das cuenta de que no estamos hablando de direcciones absolutas sino de direcciones relativas? Revisaremos los registros, que son muy útiles para esto, en la siguiente sección.

**Segmentos**. Al acceder a la memoria en Cairo usamos segmentos. Los segmentos son áreas de memoria. Estos segmentos luego se conectarán para crear una lista de segmentos: nuestra memoria. Como mencionamos antes, las direcciones en El Cairo son relativas: no solo son relativas entre sí sino también con el segmento al que pertenecen. Por lo tanto, una dirección en El Cairo se representa así: `<segmento>:<desplazamiento>`. Donde `<segmento>` es el número de segmento (no lo sabemos cuando escribimos el programa, se asigna cuando ejecutamos nuestro programa); y `<offset>` es la posición de la dirección relativa al segmento. Esta forma de representar las direcciones se llama "reubicable": al final, cuando ejecutamos nuestro programa, estas celdas de memoria se reubicarán para que la memoria termine siendo continua.

Los dos segmentos que requiere cualquier programa de El Cairo son:

* **Segmento 0** - Segmento de programa. Los programas de El Cairo se mantienen en el segmento de programas. Este segmento tiene una longitud fija y contiene la representación numérica del programa de El Cairo. El registro `pc` comienza aquí.
* **Segmento 1** - Segmento de ejecución. Aquí es donde comienzan los registros `ap` y `fp`, y donde se almacenan los datos generados durante la ejecución de un programa Cairo (variables, direcciones de retorno para llamadas a funciones, etc.). La longitud del segmento de ejecución es variable, ya que depende, por ejemplo, de la entrada del programa.

Como vimos antes, podemos usar funciones integradas que tendrían su propio segmento de memoria. Compilar [builtins/cairo/hash.cairo](./builtins/cairo/hash.cairo) (`cairo-compile builtins/cairo/hash.cairo --output hash_compiled.json`) o (`cairo-compile hash.cairo --output hash_compiled.json`) y ejecutarlo con el `--print-memory` flag (`cairo-run --program hash_compiled.json --print_output --layout=small --print_memory`). Observe que tenemos valores en los segmentos Programa (0), Ejecución (1), Salida (2), Pedersen (3) y Comprobación de rango (4).


<h3>Registros</h3>

Sabemos que el RISC algebraico opera en celdas de memoria (no hay registros de propósito general). Una instrucción Cairo puede manejar hasta 3 valores de la memoria: puede realizar una operación aritmética (ya sea suma o multiplicación) en dos de ellos y almacenar el resultado en el tercero. En total, cada instrucción usa 4 accesos a la memoria ya que primero usa uno para buscar la instrucción([Cairo Whitepaper](https://eprint.iacr.org/2021/1063.pdf)).

La CPU de Cairo opera en 3 registros (`pc`, `ap` y `fp`) que se utilizan para especificar en qué celdas de memoria opera la instrucción. Para cada uno de los 3 valores en una instrucción, puede elegir una dirección de la forma $ap + off$ o $fp + off$ donde $off$ es un desplazamiento constante en el rango $[−215, 215)$. Por lo tanto, una instrucción puede involucrar 3 celdas de memoria de $2 · 216 = 131072$. En muchos aspectos, esto es similar a tener tantos registros (implementado de una manera mucho más económica). Un desplazamiento es una suma o resta a una celda en la memoria, por ejemplo, $[fp - 1] = [ap - 2] + [fp + 4]$ donde $-1$, $-2$ y $+4$ son compensaciones. Los desplazamientos nos permiten tener posiciones de memoria relativas.

* El "puntero de asignación" (ap) apunta a la primera celda de memoria que el programa no ha utilizado hasta el momento. Muchas instrucciones pueden aumentar el valor `ap` en uno para indicar que la instrucción ha utilizado otra celda de memoria; similar a lo que hace `serialize_word` cuando usa la memoria integrada de salida en `output_ptr` y luego actualiza su valor.

* Cuando se inicia una función, el registro de "puntero de cuadro" (fp) se inicializa al valor actual de ap. Durante todo el alcance de la función (excluyendo las llamadas a funciones internas), el valor de `fp` permanece constante. En particular, cuando una función, foo, llama a una función interna, bar, el valor de `fp` cambia cuando comienza bar, pero se restaura cuando termina bar. La idea es que `ap` puede cambiar de forma desconocida cuando se llama a una función interna, por lo que no se puede usar de manera confiable para acceder a las variables y argumentos locales de la función original después de eso. Por lo tanto, `fp` sirve como ancla para acceder a estos valores.

* El registro del “contador de programa” (pc) apunta a la dirección en la memoria de la instrucción Cairo actual que se va a ejecutar. El `pc` comienza al principio del segmento del programa; segmento 0. La CPU (1) obtiene el valor de esa celda de memoria, (2) ejecuta la instrucción expresada por ese valor (que puede afectar las celdas de memoria o cambiar el flujo del programa asignando un valor diferente a la PC), (3 ) mueve `pc` a la siguiente instrucción y (4) repite este proceso. En otras palabras, el contador de programa (pc) mantiene la dirección de la instrucción actual. Normalmente avanza en 1 o 2 por instrucción según el tamaño de la instrucción (cuando la instrucción actual ocupa dos elementos de campo, el contador del programa avanza en 2 para la siguiente instrucción).

Compila y ejecuta [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo). El ejemplo imprimirá:

```Bash
1. ap address: 1:3; fp address: 1:3
2. ap address: 1:4; fp address: 1:3; value at address [AP - 1] is 100.
3. ap address: 1:5; fp address: 1:3; value at address [AP - 1] is 200.
4. ap address: 1:6; fp address: 1:3; value at address [AP - 1] is 2:0 (WITH OUPUT_PTR).
5. ap address: 1:9; fp address: 1:8; value at address [AP - 1] is 300 (FOO() FUNCTION).
6. ap address: 1:9; fp address: 1:8; value at address [AP + 2] is 500; we can not get the value at [AP + 1] since it is unknown.
7. ap address: 1:10; fp address: 1:3; value at address [AP - 1] is 600.
```
Nota:
1. `fp` se inicializa con el mismo valor que toma `ap` al comienzo del alcance de una función: durante el alcance de `main` es `1:3`, durante el alcance de `foo` es `1:8 `. Cuando el alcance de `foo` finaliza y el programa vuelve a `main`, `fp` es `1:3` de nuevo.
2. Puede omitir celdas de memoria. Durante la instrucción 6. establecemos el valor en `[ap+2]` sin definir `[ap+1]`.
3. `[ap]` puede almacenar fieltros pero también direcciones reubicables como en la instrucción 4. donde almacenamos el valor de `output_ptr`.
4. `ap` avanza de uno en uno excepto cuando se llama a una función y al principio. Nuestro `ap` comienza apuntando a 1:3, porque las tres primeras celdas de memoria del segmento de ejecución (1:0, 1:1, 1:2) indican los otros segmentos que se utilizarán, en este caso los segmentos 2, 3 y 4. El segmento 2 se usa para la salida incorporada, y los segmentos 3 y 4 son segmentos vacíos que se usan para los valores de retorno de `fp` en una pc.

Ejecute [registers/cairo/ap_fp_example.cairo](registers/cairo/ap_fp_example.cairo) con las flags `--print_info` y `--print_segments`. Nota:

5. Gracias a `--print_info` podemos ver los valores del registro después de la ejecución.

```Bash
Register values after execution:
pc = 4:0
ap = 1:11
fp = 3:0
```

Los valores finales de los registros también son reubicables. `ap` permanece en el segmento de ejecución (1), mientras que los valores devueltos de `fp` y `pc` reciben sus propios segmentos por razones técnicas.

6. Gracias a `--print_segments` podemos ver la tabla de reubicación de segmentos;

```Bash
Segment relocation table:
0     1
1     29
2     339
3     340
4     340
```

La tabla muestra las direcciones reales (no relativas) de las celdas de memoria utilizadas por cada segmento después de la reubicación. Los segmentos 3-4 son segmentos vacíos que se utilizan para devolver valores de `fp` y `pc`. Como puede ver, la memoria termina siendo continua: por ejemplo, el segmento 2 comienza en la celda 29, cuando termina el segmento 1 y continúa hasta la celda 338, recuerde que establecemos el valor en `[ap+300]` para que las celdas 40- 337 fueron llenados automáticamente por el probador. Luego, el segmento 2 comienza en la siguiente dirección, 339.


<h3>Tipos/Referencias</h3>


<h3>Hints</h3>

`EN CONSTRUCCIÓN`

El código de Python se puede invocar con el bloque %{ %} llamado sugerencia, que se ejecuta justo antes de la siguiente instrucción de Cairo. La sugerencia puede interactuar con las variables/memoria del programa como se muestra en el siguiente ejemplo de código. Tenga en cuenta que la sugerencia no es en realidad parte del programa Cairo y, por lo tanto, puede ser reemplazada por un probador malicioso. Podemos ejecutar un programa Cairo con el indicador `--program_input`, que permite proporcionar un archivo de entrada json al que se puede hacer referencia dentro de una sugerencia ([documentación de Cairo](https://starknet.io/docs/reference/syntax.html#hints )).

```Rust
alloc_locals;
%{ memory[ap] = 100 %}  // Assign to memory.
[ap] = [ap], ap++;  // Increment `ap` after using it in the hint.
assert [ap - 1] = 100;  // Assert the value has some property.

local a;
let b = 7;
%{
    # Assigns the value '9' to the local variable 'a'.
    ids.a = 3 ** 2
    c = ids.b * 2  # Read a reference inside a hint.
%}
```
Nota: Tenga en cuenta que puede acceder a la dirección de un puntero a una estructura usando ids.struct_ptr.address_ y puede usar memory[addr] para el valor de la celda de memoria en la dirección addr.

<h3>SHARP</h3>

<h2 align="center" id="cairo_vm">Cairo VM</h2>
<h3><a href="https://github.com/FuzzingLabs/thoth">Disassembler(Thoth)</a></h3>
<h3><a href="https://github.com/crytic/amarna">Amarna</a></h3>

<hr>

#### Fuentes

[<https://eprint.iacr.org/2021/1063.pdf>
, <https://arxiv.org/pdf/2109.14534.pdf>
, <https://www.cairo-lang.org/cairo-for-blockchain-developers>
, <https://www.cairo-lang.org/docs/how_cairo_works/index.html>
, <https://github.com/FuzzingLabs/thoth>
, <https://github.com/crytic/amarna>]
