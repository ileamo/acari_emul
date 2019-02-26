# Демонстрация системы БОГАТКА-КЛЕЩ

Во время демонстрации будут запущены контейнеры docker с базой данных, сервером и эмулятором 25 клиентов.

## Требования к хосту:
должен быть установлен [docker](https://docs.docker.com/install/#support)

## Запуск
```bash
git clone https://github.com/ileamo/acari_emul
cd acari_emul
./run.sh
```
Можно проконтролировать, что запустилось три контейнера
```bash
docker ps
```
## Работа с демо
В браузере заходим на демонстрационный сервер https://localhost:50020 \
Имя - admin\
Пароль - admin

Чтобы остановить демонстрацию наберите
```bash
./stop.sh
```

Если Вы меняли конфигурацию на демо сервере, то после остановки и последующего запуска все Ваши изменения пропадут. Если Вы хотите оставить изменения для последующих опытов, то перед остановкой сделайте коммит:
```bash
./commit.sh
./stop.sh
```

## Удаление
Для полного удаления всех загруженных образов выполните
```bash
docker rmi ileamo/acari-server-db:init-25 ileamo/acari-client ileamo/acari-server
```

## Возможные проблемы
При обращении к серверу выдается ошибка
```
Internal Server Error
```
После запуска сервера(./run.sh) надо подождать 30-60 сек, чтобы все проинициировалось.
