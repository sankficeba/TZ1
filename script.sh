#!/bin/bash
if (($# != 2)); then
echo "На вход программы поступило "$# "аргументов, ожидалось 2 аргумента"
exit 1
fi

input_dir="$1"
output_dir="$2"

if [[ ! -d "$input_dir" ]]; then
    echo "Входная директория '$input_dir' не существует"
    exit 1
fi
if [[ ! -d "$output_dir" ]]; then
    echo "Выходная директория '$output_dir' не существует"
    exit 1
fi

if [[ ! -r "$input_dir" ]]; then
    echo "Нет разрешения на чтение файлов во входной директории '$input_dir'"
    exit 1
fi
if [[ ! -r "$output_dir" || ! -w "$output_dir" ]]; then
    echo "Нет разрешения на чтение и/или запись файлов в выходной директории '$output_dir'"
    exit 1
fi

echo "Файлы, находящихся непосредственно во входной директории '$input_dir' :"
find "$input_dir" -maxdepth 1 -type f | while read -r file; do
    echo $(basename "$file")
done
echo

echo "Директории, находящиеся непосредственно во входной директории '$input_dir' :"
find "$input_dir" -maxdepth 1 -not -name $(basename "$input_dir") -type d | while read -r dir; do
    echo $(basename "$dir")
done
echo

echo "Производим копирование файлов из '$input_dir' в '$output_dir'"
find "$input_dir" -type f | while read -r file; do
    filename=$(basename "$file")
    if [[ "${filename:0:1}" == "." ]]; then
        filename="${filename:1}"
        if [[ -f "$output_dir/.$filename" ]]; then
            i=0
            new_filename=$filename
            while [[ -f "$output_dir/.$new_filename" ]]; do
                i=$(($i+1))
                new_filename="${filename%.*}_$i.${filename##*.}"
            done
            echo "Файл '.$filename' уже есть, копируем как '.$new_filename'"
            cp "$file" "$output_dir/.$new_filename"
        else
            cp "$file" "$output_dir/.$filename"
            echo "Файл '.$filename' успешно скопирован"
        fi
    else
        if [[ -f "$output_dir/$filename" ]]; then
            i=0
            new_filename=$filename
            while [[ -f "$output_dir/$new_filename" ]]; do
                i=$(($i+1))
                new_filename="${filename%.*}_$i.${filename##*.}"
            done
            echo "Файл '$filename' уже есть, копируем как '$new_filename'"
            cp "$file" "$output_dir/$new_filename"
        else
            cp "$file" "$output_dir/$filename"
            echo "Файл '$filename' успешно скопирован"
        fi
    fi
done

echo "Все файлы из '$input_dir' скопированы в '$output_dir'"
