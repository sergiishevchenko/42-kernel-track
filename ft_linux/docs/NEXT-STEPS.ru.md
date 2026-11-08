# Что делать дальше — пошаговая инструкция

Код в репозитории готов. Дальше вся работа идёт на **виртуальной машине**.  
Следуй шагам по порядку. Не перескакивай фазы.

Читать параллельно: [учебник LFS](lfs-ru/README.md) · [PLAN.md](../PLAN.md)

---

## Статус сейчас

| Что | Готово? |
|-----|---------|
| Скрипты, конфиги, docs | Да |
| Гипервизор | **UTM** (уже есть) |
| VM / хост Linux | Уже есть — проверь ресурсы и второй диск |
| Сборка дистрибутива | Нет |
| Сдача | Нет |

---

## Шаг 0. Подготовка на Mac (до VM)

### 0.1. Гипервизор

У тебя уже есть **UTM** — этого достаточно.  
(VirtualBox/VMware не нужны.)

### 0.2. ISO хост-системы

Если Linux в UTM **уже установлен** — этот шаг **пропусти**.

Если понадобится новая чистая VM:
- для Apple Silicon (M1/M2/M3): бери **ARM64** ISO (Debian ARM64 / Ubuntu ARM64)
- для Intel Mac: обычный **amd64** ISO

### 0.3. (Опционально) Скачай исходники на Mac

```bash
bash sources/download.sh
```

~1.5 GB — потом скопируешь в VM (или качай уже внутри VM).

### 0.4. Твой login

**`sshevche`** — уже прописан в `LOGIN`, configs и скриптах.

---

## Шаг 1. VM в UTM

### Если VM с Linux уже есть (твой случай)

1. Запусти её  
2. Проверь ресурсы: желательно **4+ GB RAM**, **2+ CPU**, свободно **30+ GB**  
3. Сеть: Shared Network — должен быть интернет  

Архитектура: если Mac на Apple Silicon и Linux ARM64 — ft_linux тоже будет **aarch64**. Для задания 42 это нормально (разрешены 32/64-bit). 

### Диск под LFS (важно)

Скрипт `01-prepare-disk.sh` **стирает** диск.

В UTM удобнее так:
1. Выключи VM  
2. Edit → Drives → **New…** → создай второй диск **30–40 GB**  
3. Включи VM  
4. Проверь: `lsblk` — появится, например, `/dev/vdb` или `/dev/sdb`  
5. Размечай **только второй диск**, не тот, где стоит текущий Linux  

### Драйверы ядра (на будущее, шаг 12)

В UTM часто VirtIO. В `menuconfig` ядра включи:
- VirtIO block / VirtIO SCSI (диск)
- VirtIO network (сеть)
- или e1000, если в UTM выбран эмулированный Intel NIC

Посмотреть текущий NIC в хосте:

```bash
ip link
lspci 2>/dev/null | grep -i net || true
```

---

## Шаг 1b. (Если создаёшь новую VM с нуля)

### Настройки UTM

| Параметр | Значение |
|----------|----------|
| System | Virtualize (Apple Virtualization или QEMU) |
| RAM | минимум 4 GB (лучше 8) |
| CPU | 2+ ядра |
| Диск хоста | 20+ GB |
| Второй диск под LFS | 30–40 GB |
| Сеть | Shared Network |

После установки хоста (или на уже существующей VM) поставь инструменты:

```bash
sudo apt update
sudo apt install -y build-essential bison gawk texinfo \
  python3 wget curl xz-utils git
```

---

## Шаг 2. Скопируй проект в VM

Варианты:
- `git clone` репозитория  
- или shared folder / `scp` всей папки `ft_linux`

Перейди в каталог проекта:

```bash
cd ft_linux
```

---

## Шаг 3. Проверь хост

```bash
bash scripts/00-check-host.sh
```

- Все **FAIL** должны исчезнуть  
- Если чего-то нет — доустанови пакеты и повтори  

---

## Шаг 4. Скачай исходники (если ещё нет)

```bash
bash sources/download.sh
```

Дождись конца и проверки MD5.  
При обрыве просто запусти скрипт снова.

---

## Шаг 5. Разметь диск под LFS

**Важно:** это уничтожит данные на выбранном диске.

Узнай имя диска:

```bash
lsblk
```

Обычно второй диск или основной — `/dev/sda` / `/dev/sdb`.  
Если хост стоит на том же диске — **нельзя** просто стереть его.  
Для LFS удобнее:

- либо отдельный второй диск в VM только под LFS,  
- либо ставить хост на Live/другой том и собирать LFS на целевой диск.

Когда целевой диск выбран (пример для UTM: `/dev/vdb` или `/dev/sdb`):

```bash
sudo bash scripts/01-prepare-disk.sh /dev/vdb
```

Подтверди словом `YES`.

Ожидаемый результат:

```text
/boot  -> /dev/sdX1  (ext2)
/      -> /dev/sdX2  (ext4)  смонтирован в /mnt/lfs
swap   -> /dev/sdX3
```

Проверка:

```bash
export LFS=/mnt/lfs
df -h | grep lfs
swapon --show
```

Скопируй исходники:

```bash
mkdir -pv $LFS/sources
cp -v sources/*.{tar.*,tgz,patch} $LFS/sources/ 2>/dev/null || \
  cp -v sources/* $LFS/sources/
```

---

## Шаг 6. Создай пользователя lfs

```bash
sudo bash scripts/setup-lfs-user.sh
su - lfs
```

Проверь:

```bash
echo $LFS
echo $PATH
ls $LFS/sources | head
```

---

## Шаг 7. Кросс-тулчейн (долго)

От пользователя `lfs`:

```bash
bash /path/to/ft_linux/scripts/02-toolchain-cross.sh
```

Время: **4–8 часов**.  
Лучше запускать в `tmux` / `screen`.

После успеха сделай **snapshot VM**.

---

## Шаг 8. Временные инструменты (долго)

Всё ещё как `lfs`:

```bash
bash /path/to/ft_linux/scripts/03-toolchain-temp.sh
```

Ещё **4–8 часов**.  
Снова snapshot.

```bash
exit   # выйти из lfs → обратно в root
```

---

## Шаг 9. Chroot

Как root:

```bash
export LFS=/mnt/lfs
sudo bash scripts/04-chroot-setup.sh
```

Скопируй скрипты внутрь будущей системы (удобно):

```bash
mkdir -pv $LFS/root/ft_linux
cp -a scripts configs $LFS/root/ft_linux/
```

Войди в chroot:

```bash
chroot "$LFS" /usr/bin/env -i \
  HOME=/root \
  TERM="$TERM" \
  PS1='(lfs chroot) \u:\w\$ ' \
  PATH=/usr/bin:/usr/sbin \
  MAKEFLAGS="-j$(nproc)" \
  /bin/bash --login
```

Приглашение должно быть `(lfs chroot)`.

---

## Шаг 10. Сборка основной системы (самый долгий этап)

Внутри chroot:

```bash
cd /root/ft_linux
bash scripts/05-build-system.sh
```

Время: **10–20 часов**.

Если упало:

```bash
bash scripts/05-build-system.sh --from <имя_пакета>
```

Список пакетов:

```bash
bash scripts/05-build-system.sh --list
```

При странных ошибках `configure`/`make` — смотри официальный LFS Ch.8 и русский учебник [07-basic-system.md](lfs-ru/07-basic-system.md).

Особенно внимательно доведи **udev/eudev** по книге LFS, если скрипт предупредит.

Snapshot после успеха.

---

## Шаг 11. Конфиги системы

Login уже задан: **sshevche**.

```bash
bash scripts/apply-configs.sh
passwd root
```

Проверь/поправь при необходимости:

- `/etc/fstab` — правильные `/dev/sdXN`
- `/etc/hostname` — должно быть `sshevche`
- `/etc/sysconfig/ifconfig.eth0` — сеть (static или dhcp)

---

## Шаг 12. Ядро

```bash
bash scripts/06-build-kernel.sh sshevche
# или: bash scripts/06-build-kernel.sh
```

В `menuconfig` обязательно:

1. **Local version** = `-sshevche`
2. Loadable modules  
3. `devtmpfs`  
4. ext4 / proc / sysfs / tmpfs  
5. TCP/IP  
6. Драйвер сетевой карты VM (часто **e1000** для VirtualBox)

Проверка после сборки:

```bash
ls /boot/vmlinuz-*-sshevche
ls -d /usr/src/kernel-*
```

---

## Шаг 13. GRUB

```bash
bash scripts/07-configure-grub.sh sshevche /dev/sdX /dev/sdX2
```

Подставь свой диск и root-раздел.

---

## Шаг 14. Выход и перезагрузка

```bash
exit   # выйти из chroot
```

На хосте:

```bash
export LFS=/mnt/lfs
bash scripts/09-umount-and-reboot.sh
reboot
```

В Boot Order VM выбери диск с ft_linux.

---

## Шаг 15. Проверка своей ОС

Войди как `root`.

```bash
uname -r          # должно быть ...-sshevche
hostname          # = sshevche
ping -c3 8.8.8.8
ping -c3 google.com
```

Полная проверка:

```bash
bash /root/ft_linux/scripts/08-final-checks.sh sshevche
```

Исправь все **FAIL**.

---

## Шаг 16. Сдача

На Mac (где лежит `.vdi` / `.vmdk`):

```bash
shasum < disk.vdi
```

1. Сохрани checksum в git-репозиторий  
2. Образ диска оставь у себя для peer-evaluation  
3. Запушь репозиторий  

---

## Краткая шпаргалка команд

```text
00-check-host.sh
download.sh
01-prepare-disk.sh
setup-lfs-user.sh
02-toolchain-cross.sh      ← lfs, долго
03-toolchain-temp.sh       ← lfs, долго
04-chroot-setup.sh
chroot ...
05-build-system.sh         ← chroot, очень долго
apply-configs.sh           ← login=sshevche по умолчанию
06-build-kernel.sh
07-configure-grub.sh
exit chroot
09-umount-and-reboot.sh
reboot
08-final-checks.sh
shasum < disk.vdi
```

---

## Если что-то сломалось

| Этап | Что делать |
|------|------------|
| Нет пакетов на хосте | `apt install ...`, снова `00-check-host` |
| Нет сети в VM | NAT, проверить `ip a`, DNS |
| Упал toolchain | snapshot назад / пересобрать с начала фазы |
| Упал пакет в chroot | `--from <pkg>`, сверить с LFS book |
| Не грузится | chroot с хоста, чинить GRUB/fstab/ядро |
| Нет сети после boot | драйвер NIC в ядре + `ifconfig.eth0` |

---

## Следующее действие прямо сейчас

1. Установить VirtualBox  
2. Скачать Debian ISO  
3. Создать VM  
4. Установить Linux  
5. Скопировать репо и запустить `bash scripts/00-check-host.sh`
