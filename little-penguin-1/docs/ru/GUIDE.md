# Little Penguin — запуск на ft_linux шаг за шагом

Задание требует: *«All work must be done on your custom Linux distribution»*.
Поэтому всё, что касается ядра и модулей, выполняется в **ft_linux** (LFS в UTM),
а Mac используется только для редактирования кода, git и коммита.

## Общая схема

```
Mac                                   ft_linux (UTM, root)
───                                   ────────────────────
fetch-bootstrap.sh  ── tar.gz ──▶     install-git.sh
                     (HTTP)           build-kernel.sh torvalds   → reboot → collect 00
                                      build-kernel.sh thor       → reboot → collect 02
                                      build-kernel.sh linux-next → reboot → collect 06
                                      сборка модулей + proof.sh  (04, 05, 07)
git commit + push   ◀── tar.gz ──     pack-artifacts.sh
                     (HTTP)
```

Файлы между Mac и VM передаются через `python3 -m http.server` (Python есть и в
macOS, и в LFS). Ни ssh, ни общие папки не нужны.

Что получится в итоге:

| Задание | Что сдаётся | Откуда берётся |
|---|---|---|
| 00 | `kern.log`, `.config` | `assignment-00/collect.sh` |
| 01 | `main.c`, `Makefile` | уже в репозитории |
| 02 | `kern.log`, `Makefile.patch` | `assignment-02/collect.sh` |
| 03 | `fixed.c` | уже в репозитории |
| 04 | `main.c`, `Makefile`, `99-keyboard.rules`, `proof.log` | `assignment-04/proof.sh` |
| 05 | `main.c`, `Makefile`, `proof.log` | `assignment-05/proof.sh` |
| 06 | `kern.log` | `assignment-06/collect.sh` |
| 07 | `main.c`, `Makefile`, `proof.log` | `assignment-07/proof.sh` |
| 08 | `fixed.c` | уже в репозитории |
| 09 | `main.c`, `Makefile` | уже в репозитории |

Время: каждое ядро собирается от 30 минут до пары часов (зависит от числа ядер
CPU у VM). Всего три сборки. Если ft_linux собран под **x86_64** и работает на
Apple Silicon через эмуляцию UTM, сборка будет в разы медленнее: закладывайте
по несколько часов на ядро и запускайте её на ночь.

---

## Шаг 0. Проверка ft_linux

Исходим из того, что ft_linux уже готов: загружается из GRUB, вы входите под
`root`, работают сеть и udev (eudev). Проверьте несколько вещей, которые нужны
именно этому проекту.

1. **Система и загрузка:**
   ```bash
   uname -rm                    # например: 6.16.1-sshevche x86_64
   cat /proc/cmdline            # параметры, с которыми грузится ft_linux
   mountpoint /boot             # "/boot is a mountpoint" (отдельный раздел sda1)
   ls /boot/grub/grub.cfg /boot/config-$(uname -r)
   ```
   `build-kernel.sh` берёт `/boot/config-$(uname -r)` за основу конфига новых
   ядер, а параметры `/proc/cmdline` (например, `root=/dev/sda2 ro`) — для
   новых пунктов GRUB.
2. **Бэкенд UTM — QEMU**, а не Apple Virtualization. Без QEMU в VM нет USB, и
   задание 04 не проверить.
   UTM → VM → Edit → **Input** → *USB Support*: **USB 3.0 (XHCI)**.
   Клавиатура VM в QEMU подключается как USB-клавиатура, этого достаточно для
   задания 04. Проверка внутри VM:
   ```bash
   grep -l '^03$' /sys/bus/usb/devices/*/bInterfaceClass   # должен найтись хотя бы один HID-интерфейс
   ```
3. **Ресурсы**: желательно 4+ CPU и 4+ ГБ RAM (UTM → Edit → System).
4. **Свободно ≥ 25 ГБ** на корневом разделе, где будет `/usr/src`. Раздел
   `/boot` маленький (500 МБ), но на каждое ядро нужно всего ~30–50 МБ.
   ```bash
   df -h / /boot
   ```
   Если места мало, добавьте второй диск в UTM (Edit → Drives → New, 40 ГБ),
   загрузитесь и подключите его:
   ```bash
   lsblk                                  # новый диск без разделов, например /dev/sdb
   mkfs.ext4 /dev/sdb
   mkdir -p /usr/src/little-penguin
   mount /dev/sdb /usr/src/little-penguin
   echo '/dev/sdb /usr/src/little-penguin ext4 defaults 1 2' >> /etc/fstab
   ```
5. **Сеть и часы.** Проверьте, что интернет есть и дата правильная (с неверной
   датой не работает HTTPS):
   ```bash
   ip route                 # строка "default via 192.168.64.1" — это IP Mac
   date                     # если дата неверна: date -s "2026-11-13 20:30"
   ```

---

## Шаг 1. Подготовка на Mac

```bash
cd "/Users/serg/IT/__CODING__/42 Lausanne/42-cursus/42-kernel-track/little-penguin-1"

# исходники curl и git + сертификаты CA для ft_linux (в bootstrap/, не коммитится)
scripts/fetch-bootstrap.sh

# упаковать проект (без заглушек для редактора и мусора macOS)
COPYFILE_DISABLE=1 tar --exclude=include --exclude=compile_flags.txt \
	--exclude=.DS_Store -czf /tmp/little-penguin.tar.gz -C .. little-penguin-1

# раздать архив по HTTP
cd /tmp && python3 -m http.server 8000
```

Оставьте сервер работать до конца шага 2. IP Mac в сети UTM обычно
`192.168.64.1`. Проверить можно так: `ipconfig getifaddr bridge100`.

---

## Шаг 2. Перенос проекта в ft_linux

В консоли ft_linux под `root`:

```bash
cd /root
wget http://192.168.64.1:8000/little-penguin.tar.gz
tar -xzf little-penguin.tar.gz
cd little-penguin-1
```

После этого сервер на Mac можно остановить (`Ctrl+C`).

> Все дальнейшие команды на VM выполняются **под root из `/root/little-penguin-1`**.

---

## Шаг 3. Установка git с HTTPS

В LFS нет git, а без него не скачать дерево ядра и не сделать `git format-patch`.
Скрипт собирает `curl`, затем `git` из исходников, скачанных на шаге 1, и
ставит сертификаты в `/etc/ssl/certs/ca-bundle.crt`:

```bash
scripts/install-git.sh
```

В конце должно быть `HTTPS works.` и версия git.

Настройте имя для `Signed-off-by` в патче задания 02. По правилам
`SubmittingPatches` нужно **настоящее имя**:

```bash
git config --global user.name  "Имя Фамилия"
git config --global user.email "sshevche@student.42lausanne.ch"
```

Создайте обычного пользователя. Через него proof-скрипты проверяют права
доступа (root их обходит):

```bash
useradd -m penguin
```

Проверьте окружение. Все строки должны быть `OK`:

```bash
scripts/check-env.sh
```

---

## Шаг 4. Задание 00 — ядро Линуса

```bash
scripts/build-kernel.sh torvalds
```

Что делает скрипт:

1. Клонирует `torvalds/linux.git` в `/usr/src/little-penguin/linux`.
2. Берёт `.config` текущего ядра ft_linux (`/boot/config-$(uname -r)`), чтобы
   новое ядро точно загрузилось на этой VM. Включает `CONFIG_LOCALVERSION_AUTO`,
   `CONFIG_DEBUG_FS`, USB/HID и `make olddefconfig`.
3. Собирает ядро, ставит модули, копирует ядро в `/boot/vmlinuz-<версия>`.
4. Добавляет в конец `/boot/grub/grub.cfg` пункт `little-penguin <версия>`
   (старый файл сохраняется как `grub.cfg.bak`). Пункт ft_linux остаётся
   первым и загружается по умолчанию. Новый пункт выглядит так:
   ```
   menuentry "little-penguin 7.4.0-rc2-sshevche-g1a2b3c4d5e6f" {
       insmod ext2
       search --no-floppy --set=root --file /vmlinuz-7.4.0-rc2-sshevche-g1a2b3c4d5e6f
       linux /vmlinuz-7.4.0-rc2-sshevche-g1a2b3c4d5e6f root=/dev/sda2 ro
   }
   ```
   Раздел с ядром GRUB находит сам через `search --file`, поэтому номера
   разделов `(hd0,N)` не важны. Путь `/vmlinuz-…` указан без `/boot`, потому
   что `/boot` в ft_linux — отдельный раздел. Параметры ядра (`root=… ro`)
   берутся из текущей загрузки ft_linux.

Перезагрузитесь и **выберите в меню GRUB пункт `little-penguin …`**
(по умолчанию грузится старый ft_linux):

```bash
reboot
```

После загрузки:

```bash
uname -r                    # примерно 7.4.0-rc2-sshevche-g1a2b3c4d5e6f
cd /root/little-penguin-1
assignment-00/collect.sh
```

Суффикс `-g<хеш>` в версии добавляет как раз `CONFIG_LOCALVERSION_AUTO`.
`collect.sh` откажется сохранять лог, если запущено не то ядро.

> **Важно:** задание 00 собирается **до** шага 5, потому что `thor` меняет
> версию этого же дерева.

---

## Шаг 5. Задание 02 — `-thor_kernel`

```bash
scripts/build-kernel.sh thor
```

Скрипт дописывает `-thor_kernel` к `EXTRAVERSION` в `Makefile` дерева
(`-rc2` → `-rc2-thor_kernel`), делает `git commit -s` и пересобирает ядро.

```bash
reboot                      # в GRUB: little-penguin …-thor_kernel…
uname -r                    # должна быть подстрока -thor_kernel
cd /root/little-penguin-1
assignment-02/collect.sh
```

`collect.sh` сохраняет `kern.log`, генерирует `Makefile.patch` через
`git format-patch` и прогоняет `checkpatch.pl`. В выводе checkpatch не
должно быть ошибок (`total: 0 errors`).

---

## Шаг 6. Задание 06 — linux-next

```bash
scripts/build-kernel.sh linux-next
reboot                      # в GRUB: little-penguin …-next-YYYYMMDD…
uname -r                    # должна быть подстрока -next-
cd /root/little-penguin-1
assignment-06/collect.sh
```

Дерево `/usr/src/little-penguin/linux-next` не удаляйте: задание говорит, что
оно ещё понадобится.

---

## Шаг 7. Модули (01, 03–05, 07–09)

Модули собираются под **запущенное** ядро. Загрузитесь в любое из собранных ядер
(например, linux-next), не в старое ядро ft_linux.

```bash
cd /root/little-penguin-1
scripts/build-all-modules.sh
```

### 01 — Hello world

```bash
scripts/test-module.sh assignment-01
```

Ожидается:

```
[...] Hello world!
[...] Cleaning up module.
```

### 03 — стиль кода (по желанию)

Модуль только стилевой, но можно убедиться, что он собирается и грузится:

```bash
mkdir -p /tmp/a03 && cp assignment-03/fixed.c /tmp/a03/
echo 'obj-m += fixed.o' > /tmp/a03/Makefile
make -C /lib/modules/$(uname -r)/build M=/tmp/a03 modules
insmod /tmp/a03/fixed.ko && rmmod fixed && echo OK
```

### 04 — автозагрузка при подключении USB-клавиатуры

```bash
assignment-04/proof.sh
```

Скрипт:

1. Ставит модуль в `/lib/modules/$(uname -r)/` (подкаталог `updates` или
   `extra`, в зависимости от версии ядра) и выполняет `depmod -a`.
2. Ставит правило `99-keyboard.rules` в `/etc/udev/rules.d/`.
3. Выгружает модуль и находит USB-клавиатуру VM (интерфейс класса HID,
   boot-протокол keyboard).
4. Показывает через `udevadm test`, что правило срабатывает.
5. «Переподключает» клавиатуру программно: `authorized` 0 → 1. Ядро при этом
   заново создаёт USB-интерфейсы и шлёт события `add`, как при физическом
   подключении. Во время этого клавиатура VM на секунду перестаёт реагировать,
   это нормально.
6. Проверяет, что `main` загружен, и пишет всё в `assignment-04/proof.log`.

В `proof.log` должно быть:

- `lsmod before replug` → `main is not loaded`;
- строка из `udevadm test` с `/sbin/modprobe main`;
- `lsmod after replug` → строка `main …`;
- в `dmesg` → `Hello world!`.

Если клавиатура не найдена (`No USB keyboard found`), скрипт попросит
подключить её вручную. В UTM: подключите физическую USB-клавиатуру к Mac и
пробросьте её в VM через значок USB в панели UTM.

### 05 — misc-устройство `/dev/fortytwo`

```bash
assignment-05/proof.sh
```

Ожидается в `assignment-05/proof.log`:

- `crw-rw-rw- … /dev/fortytwo` (динамический minor, права 0666);
- `cat` от пользователя `penguin` → `sshevche`;
- `echo -n sshevche >` → `write succeeded`;
- `echo -n wrong >` → `Invalid argument` и `write failed as expected`;
- после `rmmod` → `/dev/fortytwo removed`.

Запись сравнивается строго: `echo sshevche` (с `\n`) тоже вернёт ошибку,
верный вариант — `echo -n sshevche`.

### 07 — debugfs

```bash
assignment-07/proof.sh
```

Скрипт монтирует debugfs (если нужно) и делает `chmod o+rx /sys/kernel/debug`.
Это та самая «good old chown» часть задания: без неё обычный пользователь не
увидит каталог. Ожидается в `assignment-07/proof.log`:

- `id`: читается и пишется пользователем `penguin` (права `-rw-rw-rw-`);
- `jiffies`: два разных числа, запись → `Permission denied`;
- `foo`: запись от `penguin` → `Permission denied`, от root → проходит,
  чтение от `penguin` → `hello from root`; запись 4097 байт → `No space left on device`;
- после `rmmod` → `/sys/kernel/debug/fortytwo removed`.

### 08 — `/dev/reverse` (по желанию)

```bash
mkdir -p /tmp/a08 && cp assignment-08/fixed.c /tmp/a08/
echo 'obj-m += fixed.o' > /tmp/a08/Makefile
make -C /lib/modules/$(uname -r)/build M=/tmp/a08 modules
insmod /tmp/a08/fixed.ko
echo -n hello > /dev/reverse && cat /dev/reverse; echo    # olleh
rmmod fixed
```

### 09 — `/proc/mymounts`

```bash
cd assignment-09
make
insmod main.ko
cat /proc/mymounts
rmmod main
cd ..
```

Ожидается список вида:

```
root /
proc /proc
sys /sys
dev /dev
run /run
...
```

Для сравнения: `cat /proc/mounts`. Модуль подключает внутренний заголовок ядра
`fs/mount.h`, поэтому `/lib/modules/$(uname -r)/build` должен указывать на
полное дерево исходников. `build-kernel.sh` создаёт эту ссылку сам.

---

## Шаг 8. Проверка на VM

```bash
scripts/verify-submission.sh
```

На VM строка `Git check` будет `SKIP` (там нет git-репозитория проекта), всё
остальное должно быть `OK`.

---

## Шаг 9. Перенос результатов на Mac

На ft_linux:

```bash
scripts/pack-artifacts.sh                # → /tmp/little-penguin-artifacts.tar.gz
ip -4 addr show | grep inet              # IP VM, например 192.168.64.5
cd /tmp && python3 -m http.server 8000
```

На Mac:

```bash
cd "/Users/serg/IT/__CODING__/42 Lausanne/42-cursus/42-kernel-track/little-penguin-1"
curl -O http://192.168.64.5:8000/little-penguin-artifacts.tar.gz
tar -xzf little-penguin-artifacts.tar.gz
rm little-penguin-artifacts.tar.gz
```

Затем остановите сервер на VM (`Ctrl+C`).

---

## Шаг 10. Финальная проверка и коммит на Mac

```bash
scripts/verify-submission.sh
```

Единственный `FAIL` должен быть в `Git check` (файлы ещё не закоммичены).
Коммит:

```bash
cd ..
git add little-penguin-1
git commit -m "Add little-penguin solutions, boot logs and proofs"
git push
little-penguin-1/scripts/verify-submission.sh    # теперь всё OK
```
