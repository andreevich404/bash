#!/bin/bash
# Скрипт для изменения домашней директории и пароля пользователя

echo "=== Изменение параметров пользователя ==="

read -p "Введите имя пользователя: " username

# Проверка существования пользователя
if ! id "$username" &>/dev/null; then
    echo "Ошибка: Пользователь $username не существует!"
    exit 1
fi

echo "Текущая информация о пользователе:"
echo "=== Базовая информация ==="
id "$username"

echo -e "\n=== Подробная информация из /etc/passwd ==="
if grep "^$username:" /etc/passwd &>/dev/null; then
    user_info=$(grep "^$username:" /etc/passwd)
    IFS=':' read -r user_name password uid gid gecos home shell <<< "$user_info"
    echo "Имя пользователя: $user_name"
    echo "UID: $uid"
    echo "GID: $gid"
    echo "Комментарий: $gecos"
    echo "Домашняя директория: $home"
    echo "Оболочка: $shell"
else
    echo "Информация не найдена в /etc/passwd"
fi

echo -e "\n=== Группы пользователя ==="
groups "$username"

echo -e "\n=== Домашняя директория ==="
echo "$(eval echo ~$username)"

# Проверка существования домашней директории
if [ -d "$(eval echo ~$username)" ]; then
    echo "Статус: Существует"
else
    echo "Статус: Не существует"
fi

# Смена домашней директории
echo -e "\n=== Изменение домашней директории ==="
read -p "Введите новую домашнюю директорию (или Enter чтобы пропустить): " new_home
if [ -n "$new_home" ]; then
    echo "Изменение домашней директории на $new_home..."
    
    # Проверяем, существует ли новая директория
    if [ ! -d "$new_home" ]; then
        read -p "Директория не существует. Создать? (y/n): " create_dir
        if [ "$create_dir" = "y" ] || [ "$create_dir" = "Y" ]; then
            sudo mkdir -p "$new_home" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Директория создана."
            else
                echo "Ошибка: Не удалось создать директорию!"
            fi
        fi
    fi
    
    if sudo usermod -d "$new_home" "$username" 2>/dev/null; then
        echo "Домашняя директория успешно изменена!"
        
        # Копируем файлы из старой домашней директории в новую
        old_home=$(eval echo ~$username)
        if [ -d "$old_home" ] && [ "$old_home" != "$new_home" ]; then
            read -p "Скопировать файлы из старой домашней директории? (y/n): " copy_files
            if [ "$copy_files" = "y" ] || [ "$copy_files" = "Y" ]; then
                sudo cp -r "$old_home"/. "$new_home"/ 2>/dev/null && \
                sudo chown -R "$username:$username" "$new_home" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "Файлы успешно скопированы."
                else
                    echo "Ошибка при копировании файлов."
                fi
            fi
        fi
    else
        echo "Ошибка: Не удалось изменить домашнюю директорию!"
    fi
fi

# Смена пароля
echo -e "\n=== Изменение пароля ==="
read -p "Хотите изменить пароль пользователя? (y/n): " change_pass
if [ "$change_pass" = "y" ] || [ "$change_pass" = "Y" ]; then
    echo "Изменение пароля для пользователя $username..."
    if sudo passwd "$username"; then
        echo "Пароль успешно изменен!"
    else
        echo "Ошибка: Не удалось изменить пароль!"
    fi
fi

# Вывод обновленной информации
echo -e "\n=== Обновленная информация о пользователе ==="
id "$username"
echo -e "\nДомашняя директория: $(eval echo ~$username)"

# Проверка существования новой домашней директории
if [ -n "$new_home" ]; then
    if [ -d "$new_home" ]; then
        echo "Статус домашней директории: Существует"
        echo "Права доступа: $(ls -ld "$new_home" | awk '{print $1}')"
        echo "Владелец: $(ls -ld "$new_home" | awk '{print $3}')"
    else
        echo "Статус домашней директории: Не существует"
    fi
fi

echo -e "\n=== Дополнительная информация ==="
echo "Время последнего входа:"
last "$username" | head -1 2>/dev/null || echo "Информация недоступна"

echo -e "\nТекущие сессии:"
who | grep "$username" 2>/dev/null || echo "Нет активных сессий"
