<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="psg_it.Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="\style\bootstrap.css">
    <link rel="stylesheet" href="\style\bootstrap-theme.css">
    <script src="\style\bootstrap.js"></script>
    <link rel="stylesheet" href="\style\syte.css">
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
</head>
<body>
    <style type="text/css">
        #prBarLine {
            position: relative;
            display: inline-block;
            padding: 1px;
            border: 1px solid rgb(;200,200,200&#041;;
            height: 6px;
            margin-top: .4em;
            width: 300px;
        }
        #prBarLineBlock {
            position: relative;
            height: 100%;
            background-color: rgba(;0, 85, 204, 0.8&#041;;
        }
    </style>
    <form id="mainForm" runat="server">
        <div class = "col-lg-12">
            <!--область настройки-->
            <div class="col-lg-4 load" id="dropZone">
                <div class="load dnd">
                    <b>Загрузить    </b>
                    <p><b>+</b></p>
                    <img src="\img\list_new.png"/>
                    <div class="counter">0</div>
                </div>
                <!--блок загрузки-->
                
            </div>
            <div class = "col-lg-8">
                <div id="dropBox" class="exif-outer">
                    <div id="dropTitle" class="exif-inner">Перетащите файл в эту область, или кликните сюда для выбора.</div>
                    <div id="progressBar" class="exif-inner" style="display:none;">
                        <div id="prBarLine">
                            <div id="prBarLineBlock" style="width:0%">
                                @*А это прогресс бар*@
                            </div>
                        </div>
                        <div id="prBarText"></div>
                    </div>
                </div>
            </div>
        </div>
        <div class = "col-lg-12" id="test">
            <!--таблица-->
            test2
        </div>
    </form>
    <script type="text/javascript">
        var uploadPath = "/upload"; // Метод Post контроллера получающего файл

        $(document).ready(function () {
            // Проверяем поддерживает ли браузер FileAPI и XmlHttpRequest
            if (window.File && window.FileReader && window.FileList && window.Blob && new XMLHttpRequest().upload) {
                //var fileInput = $('#fileInput'); //контрол Input для выбора файлов
                //// Подписываемся на события выбора файлов через контрол Input
                //// (доступ к колекции файлов FileList можно получить через свойство files - this.files)
                //fileInput.bind({
                //    change: function () {
                //        displayFiles(this.files); //Запускаем процесс отображения файлов и отправки их на сервер
                //    }
                //});
                bind_dropBox(); // Привязываем события Drag'n'Drop - к соответствующему объекту
            }
        });

        function bind_dropBox() {
            var dropBox = $('#dropBox'); //контрол DragDrop
            dropBox.bind({
                dragenter: function (e) {
                    e.preventDefault();  // Здесь и далее необходимо пресечь распространение события, чтобы исключить
                    e.stopPropagation(); // загрузку изображения браузером
                    $(this).addClass('highlighted');
                },
                dragover: function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (!($(this).hasClass('highlighted'))) { $(this).addClass('highlighted'); }
                },
                dragleave: function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('highlighted');
                },
                drop: function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(this).removeClass('highlighted');
                    var dt = e.originalEvent.dataTransfer;

                    if (dt.files.length == 0) {return;}
                    //Нам нужен только первый файл
                    var file = dt.files[0];
                    sendFile(file);
                }
            });
        }

        function sendFile(file) {
            //Показываем индикатор прогресса
            $('#progressBar').show();
            $('#dropTitle').hide();
            getImage(file); // Отображаем динамически полученное изображение, если нужно
            uploadFile(file); // Начинаем отправку на сервер
        }


        // Функция отправки файлов на сервер
        function uploadFile(file) {
            var xhr = new XMLHttpRequest();

            var bar = $('#prBarLineBlock'); // Получаем бар для отбражения прогресса загрузки
            var value = $('#prBarText');    // Получаем поле для текста для отбражения прогресса загрузки

            xhr.upload.addEventListener("progress", function (e) {
                if (e.lengthComputable) {
                    var percentageUploaded = parseInt(e.loaded / e.total * 100);

                    // Информируем пользователя о прогрессе
                    $(bar).css("width", percentageUploaded + "%");
                    $(value).html(percentageUploaded + '% (' + fileSizeToString(e.loaded) + ' из ' + fileSizeToString(e.total) + ')');
                }
            }, false);

            // Что делаем когда все байты переданы - файл загружен
            xhr.addEventListener("load", function () {
                // ...
                $(bar).css("width", "0%");
            }, false);

            // Смотрим, что ответил сервер
            xhr.onreadystatechange = (function (ufile) {
                return function (e) {
                    if (this.readyState == 4) {
                        if (this.status == 200) {
                            $('#content').html(this.responseText); // Заменяем существующее содержимое блока <div id="content"></div> ответом полученным от сервера
                            setImgPreview(); // Повторно показываем изображение
                            bind_dropBox(); // Повторно привязываем события Drag'n'Drop к вновь полученному содержимому
                            // Если необходимо - производим манипуляции с контентом
                            //$('#dropBox').html('<img id="preview"/ style="height:auto; width:100%;">');
                            //if (imgsrc != null) {
                            //    var img = $('#preview');
                            //    $(img).attr('src', imgsrc)
                            //    }
                        }
                        else {
                            alert('Ошибка');
                        }
                        $('#progressBar').hide(); // Скрываем прогресс бар
                    }
                }
            })(file);

            xhr.open('POST', uploadPath); // Формируем запрос, адрес метода хранится в переменной uploadPath в начале скрипта

            var formData = new FormData();
            formData.append(file.name, file); // Наполняем его содержимым

            xhr.send(formData); // Отправляем на сервер
        }


        var imgsrc = null;
        function getImage(file) { // Функция отвечающая за отображение получаемого изображения в объекте DropBox
            imgsrc = null; // Обнуляем переменную для хранения изображения

            //В случае если нам нужно отфильтровать файлы по типу, например, только для изображений
            //мы сможем создать миниатюры - добавляем инструкции по фильтрованию
            if (file.type.match('^image/')) {
                //Создаем миниатюры изображений
                var reader = new FileReader();
                reader.onload = (function (ufile) { // Добавляем дополнительную функцию для сохранения в теле функции информации о файле
                    return function (e) {
                        //var img = $('#preview');
                        //$(img).attr("height", "auto"); //Задаем фиксированный размер для всех изображений - высота 100px.
                        //$(img).attr("width", "100%"); //Задаем фиксированный размер для всех изображений - высота 100px.
                        //$(img).attr('src', e.target.result);
                        imgsrc = e.target.result;
                        setImgPreview();
                    };
                })(file);

                // Начинаем чтение файла data URL.
                reader.readAsDataURL(file);
            }
            else {
                //Если необходимо - логируем, либо как-то иначе показываем пользователю, что файл 
                //выбран некорректно.
            }
        }

        function setImgPreview() {
            $('#dropBox').css("border","none");
            $('#dropBox').html('<img id="preview"/>');
            var img = $('#preview');
            if (imgsrc != null) {
                $(img).attr('src', imgsrc)
            }
        }

        //Служебная функция получения размера файла.
        function fileSizeToString(size) {
            var sizeStr = "";
            if (parseInt(size) < 1024) {
                sizeStr = size.toFixed(2) + " Bytes";
            }
            else if (parseInt(size / 1024) < 1024) {
                var sizeKB = size / 1024;
                sizeStr = sizeKB.toFixed(2) + " KB";
            }
            else if (parseInt(size / 1024 / 1024) < 1024) {
                var sizeMB = size / 1024 / 1024;
                sizeStr = sizeMB.toFixed(2) + " MB";
            }
            else {
                var sizeGB = size / 1024 / 1024 / 1024;
                sizeStr = sizeGB.toFixed(2) + " GB";
            }
            return sizeStr;
    </script>
</body>
</html>
