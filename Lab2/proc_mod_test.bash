#!/bin/bash
# Работаем активно 2 минуты
end=$((SECONDS+120))
while [ $SECONDS -lt $end ]; do
    : # Пустая команда для загрузки CPU
done
# Затем спим 3 минуты
sleep 180
