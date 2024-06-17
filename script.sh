#!/bin/bash

# Función para registrar eventos en syslog
log_event() {
    echo "[$(date)] - $1" | sudo tee -a /var/log/syslog
}

# Crear grupos
for group_name in Desarrollo Operaciones Ingeniería; do
    sudo groupadd "$group_name"
    log_event "Grupo creado: $group_name"
done

# Datos de usuarios
users_data=(
    "usuario1 grupo1 contraseña1"
    "usuario2 grupo2 contraseña2"
    "usuario3 grupo3 contraseña3"
    "usuario4 grupo1 contraseña4"
    "usuario5 grupo2 contraseña5"
    "usuario6 grupo3 contraseña6"
)

# Crear usuarios y asignarlos a grupos
for i in "${users_data[@]}"; do
    username="${users_data[i]%% *}"
    groupname="${users_data[i]#* }"
    password="${users_data[i]##* }"

    # Crear usuario
    sudo useradd -m "$username"
    log_event "Usuario creado: $username"

    # Asignar grupo al usuario
    sudo usermod -a -G "$groupname" "$username"
    log_event "Usuario agregado al grupo: $username -> $groupname"

    # Establecer contraseña
    echo "$password" | sudo passwd --stdin "$username"
    log_event "Contraseña establecida para: $username"
done

# Crear carpetas y configurar ownership y permisos
for i in "${users_data[@]}"; do
    username="${users_data[i]%% *}"
    home_dir="/home/$username"

    # Crear carpeta si no existe
    if [! -d "$home_dir" ]; then
        sudo mkdir "$home_dir"
        log_event "Carpeta creada para: $username"
    fi

    # Cambiar ownership de la carpeta al usuario
    sudo chown "$username:$username" "$home_dir"
    log_event "Ownership cambiado a: $username para la carpeta: $home_dir"

    # Configurar permisos (LWX)
    # Ejemplo: Solo lectura para el propietario, escritura y ejecución para el grupo y otros
    sudo chmod 770 "$home_dir"
    log_event "Permisos configurados para: $username en la carpeta: $home_dir"
done

echo "Script finalizado."