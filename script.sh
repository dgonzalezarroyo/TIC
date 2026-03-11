#!/bin/bash

# ============================
# 0) Comprobar si se ejecuta como root
# ============================
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse con sudo o como root."
    exit 1
fi

# ============================
# 1) Cambiar contraseñas
# ============================
echo "madrid:(Escribir contraseña para madrid)" | chpasswd
echo "profesor:(Escribir contraseña para profesor)" | chpasswd

# ============================
# 2) Cambiar timeout del GRUB
# ============================
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub

# ============================
# 3) Crear script seguro para duplicar pantallas
# ============================
cat <<'EOF' > /usr/local/bin/duplicar_pantalla.sh
#!/bin/bash

# Solo ejecutar si hay sesión gráfica
if [ -z "$DISPLAY" ]; then
    exit 0
fi

# Esperar a que MATE cargue completamente
sleep 4

# Detectar salidas conectadas
DISPLAYS=($(xrandr | awk '/ connected/{print $1}'))

# Si hay menos de 2 pantallas, no hacemos nada
if [ ${#DISPLAYS[@]} -lt 2 ]; then
    exit 0
fi

# Detectar pantalla interna (portátil)
PRIMARY=$(xrandr | awk '/ connected/ && /eDP|LVDS/ {print $1}')

# Si no hay pantalla interna, usar la primera
if [ -z "$PRIMARY" ]; then
    PRIMARY="${DISPLAYS[0]}"
fi

# Detectar pantalla externa
for OUT in "${DISPLAYS[@]}"; do
    if [ "$OUT" != "$PRIMARY" ]; then
        SECONDARY="$OUT"
        break
    fi
done

# Obtener TODAS las resoluciones del portátil (ordenadas de mayor a menor)
PRIMARY_RESOLUTIONS=($(xrandr | grep -A20 "^$PRIMARY" | grep -oP '^\s*\K[0-9]+x[0-9]+'))

# Obtener TODAS las resoluciones del proyector/monitor externo
SECONDARY_RESOLUTIONS=($(xrandr | grep -A20 "^$SECONDARY" | grep -oP '^\s*\K[0-9]+x[0-9]+'))

# Buscar la resolución más alta compatible entre ambas pantallas
BEST_COMMON_RES=""

for RES in "${PRIMARY_RESOLUTIONS[@]}"; do
    if printf '%s\n' "${SECONDARY_RESOLUTIONS[@]}" | grep -qx "$RES"; then
        BEST_COMMON_RES="$RES"
        break
    fi
done

# Si no hay resolución común, usar la máxima del portátil y que el proyector escale
if [ -z "$BEST_COMMON_RES" ]; then
    BEST_COMMON_RES="${PRIMARY_RESOLUTIONS[0]}"
fi

# Apagar secundaria para evitar conflictos
xrandr --output "$SECONDARY" --off

# Activar primaria con la mejor resolución posible
xrandr --output "$PRIMARY" --mode "$BEST_COMMON_RES" --primary

# Activar secundaria duplicando la resolución del portátil
xrandr --output "$SECONDARY" --mode "$BEST_COMMON_RES" --same-as "$PRIMARY"
EOF

chmod +x /usr/local/bin/duplicar_pantalla.sh

# ============================
# 4) Crear autostart global
# ============================
AUTOSTART_FILE="/etc/skel/.config/autostart/duplicar_pantalla.desktop"

mkdir -p /etc/skel/.config/autostart

cat <<EOF > "$AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/duplicar_pantalla.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Duplicar Pantalla
Comment=Duplica pantallas al iniciar sesión
EOF

# Aplicarlo a todos los usuarios existentes
for u in /home/*; do
    USERNAME=$(basename "$u")
    USERHOME="/home/$USERNAME"

    if [ -d "$USERHOME" ]; then
        mkdir -p "$USERHOME/.config/autostart"
        cp "$AUTOSTART_FILE" "$USERHOME/.config/autostart/"
        chown -R "$USERNAME:$USERNAME" "$USERHOME/.config/autostart"
    fi
done

# ============================
# 5) Ejecutar duplicado AHORA MISMO si hay sesión gráfica
# ============================
if [ -n "$DISPLAY" ]; then
    /usr/local/bin/duplicar_pantalla.sh
fi

# ============================
# 6) Migasfree (solo si existe)
# ============================
if command -v migasfree >/dev/null 2>&1; then
    migasfree -u
    migasfree-tags --set "(poner aquí el nombre de la etiqueta)"
else
    echo "⚠ migasfree no está instalado, se omite esta parte."
fi

# ============================
# 7) Autodestrucción
# ============================
rm -- "$0"

