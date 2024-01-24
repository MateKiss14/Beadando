#!/bin/bash

print_usage() {
    echo "Használat: $0 <művelet> <szög_fok> [tagok_szama]"
    echo "Leírás: Szinusz (sin) vagy koszinusz (cos) számítása adott szög fokban"
    echo "Opciók:"
    echo "  <művelet>     Sinusz (sin) vagy koszinusz (cos)"
    echo "  <szög_fok>     Szög mértéke fokban"
    echo "  [tagok_szama]  Opcionális: a Taylor-sor tagok száma (alapértelmezett: 3)"
}

LC_NUMERIC="C" # Tizedes vessző használata

if [ "$#" -lt 2 ]; then 
    print_usage
    exit 1
fi

while getopts ":h" opt; do
    case $opt in
        h)
            print_usage
            exit 0
            ;;
        \?)
            echo "Érvénytelen opció: -$OPTARG" >&2
            print_usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

operation=$1
angle=$2
terms=${3:-3}

# Fok-radian átalakítás
radian=$(echo "scale=15; $angle * (3.14159265358979323846 / 180)" | bc 2>/dev/null)

# Előre kiszámoljuk a faktoriálokat
factorials=()
factorials[0]=1
for ((i=1; i<=2*$terms; i++)); do
    factorials[i]=$(echo "$i *${factorials[i-1]}" | bc)
done

result=$(echo "scale=15; $radian^1 / ${factorials[1]}" | bc)
for ((n=0; n<$terms; n++)); do
    term=$(echo "radian^((2 * n) + 1)" | bc)

    # Faktoriális használata
    factorial=${factorials[(2 * n)]}

    sign=$((n % 2 == 0 ? 1 : -1))
    term_result=$(echo "scale=15; $sign * $term / $factorial" | LC_NUMERIC="C" bc 2>/dev/null)
    result=$(echo "scale=15; $result + $term_result" | bc 2>/dev/null)
done

# Tizedesjegyek megjelenítése
result=$(printf "%.10f" $result 2>/dev/null)

if [ "$operation" == "sin" ]; then
    echo "$operation $angle fok = $result"
elif [ "$operation" == "cos" ]; then
    echo "$operation $angle fok = $result"
else
    echo "Érvénytelen művelet: $operation (használható műveletek: sin, cos)"
    exit 1
fi

