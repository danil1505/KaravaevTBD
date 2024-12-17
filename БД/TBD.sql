-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Дек 17 2024 г., 09:22
-- Версия сервера: 5.5.68-MariaDB
-- Версия PHP: 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `TBD`
--

-- --------------------------------------------------------

--
-- Структура таблицы `addresses`
--

CREATE TABLE `addresses` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `street` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `house_number` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `addresses`
--

INSERT INTO `addresses` (`id`, `student_id`, `street`, `house_number`, `city`) VALUES
(1, 1, 'Ленина', '12В', 'Новосибирск'),
(2, 2, 'Кирова', '2Б', 'Новосибирск'),
(3, 3, 'Победы', '15', 'Новосибирск'),
(4, 4, 'Мира', '7', 'Новосибирск'),
(5, 5, 'Советская', '5', 'Новосибирск'),
(6, 6, 'Гагарина', '9', 'Новосибирск'),
(7, 7, 'Пушкина', '18', 'Новосибирск'),
(8, 8, 'Жукова', '21', 'Новосибирск'),
(9, 9, 'Октябрьская', '6', 'Новосибирск');

-- --------------------------------------------------------

--
-- Структура таблицы `class_times`
--

CREATE TABLE `class_times` (
  `id` int(11) NOT NULL,
  `pair_number` int(11) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `group_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `class_times`
--

INSERT INTO `class_times` (`id`, `pair_number`, `start_time`, `end_time`, `group_id`) VALUES
(1, 1, '09:00:00', '10:30:00', 1),
(2, 2, '10:40:00', '12:10:00', 1),
(3, 3, '13:00:00', '14:30:00', 2),
(4, 4, '14:40:00', '16:10:00', 3),
(5, 5, '16:20:00', '17:50:00', 4),
(6, 1, '09:00:00', '10:30:00', 5),
(7, 2, '10:40:00', '12:10:00', 6),
(8, 3, '13:00:00', '14:30:00', 9),
(9, 1, '08:00:00', '09:30:00', NULL),
(10, 2, '09:40:00', '11:10:00', NULL),
(11, 3, '11:20:00', '12:50:00', NULL),
(12, 4, '13:00:00', '14:30:00', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `direction`
--

CREATE TABLE `direction` (
  `id` int(11) NOT NULL,
  `direction_name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `direction`
--

INSERT INTO `direction` (`id`, `direction_name`) VALUES
(1, 'Инженерия'),
(2, 'Экономика'),
(3, 'Информатика');

-- --------------------------------------------------------

--
-- Структура таблицы `grades`
--

CREATE TABLE `grades` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `grade` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `grades`
--

INSERT INTO `grades` (`id`, `student_id`, `subject_id`, `grade`) VALUES
(1, 1, 1, 4),
(2, 1, 2, 5),
(3, 2, 1, 3),
(4, 3, 2, 5),
(5, 4, 3, 4),
(6, 5, 4, 5),
(7, 6, 5, 4),
(8, 7, 6, 3),
(9, 8, 7, 5),
(10, 9, 8, 4),
(11, 1, 1, 5),
(12, 1, 2, 4),
(13, 2, 1, 3),
(14, 2, 3, 4),
(15, 3, 2, 5),
(16, 3, 4, 4),
(17, 4, 5, 3),
(18, 5, 6, 4),
(19, 6, 7, 5);

--
-- Триггеры `grades`
--
DELIMITER $$
CREATE TRIGGER `check_grade_validity` BEFORE INSERT ON `grades` FOR EACH ROW BEGIN
    -- Проверяем, чтобы оценка была одной из допустимых: 2, 3, 4, 5
    IF NOT (NEW.grade IN (2, 3, 4, 5) OR NEW.grade IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Оценка должна быть 2, 3, 4 или 5, или отсутствовать';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_group_subject_avg` AFTER INSERT ON `grades` FOR EACH ROW BEGIN
    DECLARE new_avg FLOAT;
    DECLARE student_group_id INT;

    -- Получаем group_id для студента
    SELECT group_id INTO student_group_id
    FROM students
    WHERE id = NEW.student_id;

    -- Вычисляем среднюю оценку для группы по данному предмету
    SELECT AVG(grades.grade) INTO new_avg
    FROM grades
    JOIN students ON grades.student_id = students.id
    WHERE grades.subject_id = NEW.subject_id
    AND students.group_id = student_group_id
    AND grades.grade IS NOT NULL;

    -- Обновляем или вставляем среднюю оценку в таблицу
    INSERT INTO group_subject_avg (group_id, subject_id, avg_grade)
    VALUES (student_group_id, NEW.subject_id, new_avg)
    ON DUPLICATE KEY UPDATE avg_grade = new_avg;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `group_name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `groups`
--

INSERT INTO `groups` (`id`, `group_name`, `direction_id`) VALUES
(1, 'Группа 1', 1),
(2, 'Группа 2', 1),
(3, 'Группа 3', 1),
(4, 'Группа 4', 1),
(5, 'Группа 5', 2),
(6, 'Группа 6', 2),
(7, 'Группа 7', 2),
(8, 'Группа 8', 2),
(9, 'Группа 9', 3),
(10, 'Группа 10', 3),
(11, 'Группа 11', 3),
(12, 'Группа 12', 3);

-- --------------------------------------------------------

--
-- Структура таблицы `group_avg`
--

CREATE TABLE `group_avg` (
  `group_id` int(11) NOT NULL DEFAULT '0',
  `avg_grade` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `group_subject_avg`
--

CREATE TABLE `group_subject_avg` (
  `group_id` int(11) NOT NULL DEFAULT '0',
  `subject_id` int(11) NOT NULL DEFAULT '0',
  `avg_grade` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `phones`
--

CREATE TABLE `phones` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `number` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `phones`
--

INSERT INTO `phones` (`id`, `student_id`, `number`, `comment`) VALUES
(1, 1, '+7955556461', 'Мобильный телефон'),
(2, 2, '+7913256454', 'Мобильный телефон'),
(3, 3, '9546516546', 'Домашний телефон'),
(4, 4, '+7654616213', 'Мобильный телефон'),
(5, 5, '+7544545466', 'Мобильный телефон'),
(6, 6, '+756545614', 'Мобильный телефон'),
(7, 7, '45646546', 'Домашний телефон'),
(8, 8, '+7845615746', 'Рабочий телефон'),
(9, 9, '+7561546465', 'Мобильный телефон');

-- --------------------------------------------------------

--
-- Структура таблицы `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `program` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_budget` tinyint(1) DEFAULT '0',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `students`
--

INSERT INTO `students` (`id`, `first_name`, `last_name`, `middle_name`, `birth_date`, `phone`, `program`, `is_budget`, `email`, `group_id`) VALUES
(1, 'Иван', 'Иванов', 'Иванович', '2000-01-15', '+7545614654', 'Инженерия', 1, 'ivanov@example.com', 1),
(2, 'Петр', 'Петров', 'Сергеевич', '2000-05-20', '+79516542', 'Инженерия', 0, 'petrov@example.com', 1),
(3, 'Мария', 'Смирнова', 'Ивановна', '2001-07-10', '+735164644', 'Инженерия', 1, 'smirnova@example.com', 1),
(4, 'Сергей', 'Кузнецов', 'Олегович', '2000-11-22', '+715646135', 'Инженерия', 0, 'kuznetsov@example.com', 1),
(5, 'Елена', 'Попова', 'Алексеевна', '2000-03-14', '+75461264', 'Инженерия', 1, 'popova@example.com', 1),
(6, 'Анна', 'Соколова', 'Владимировна', '2001-08-01', '+7651111164', 'Инженерия', 1, 'sokolova@example.com', 1),
(7, 'Максим', 'Лебедев', 'Дмитриевич', '2000-12-18', '+75645461324', 'Инженерия', 0, 'lebedev@example.com', 1),
(8, 'Андрей', 'Новиков', 'Иванович', '2001-01-23', '+78888888', 'Инженерия', 1, 'novikov@example.com', 2),
(9, 'Виктория', 'Морозова', 'Сергеевна', '2000-05-18', '+799999999', 'Инженерия', 1, 'morozova@example.com', 2),
(10, 'Никита', 'Федоров', 'Алексеевич', '2000-10-27', '+76545645655', 'Инженерия', 0, 'fedorov@example.com', 2),
(11, 'Екатерина', 'Васильева', 'Петровна', '2000-09-12', '+7045614545', 'Экономика', 1, 'vasileva@example.com', 5),
(12, 'Дмитрий', 'Зайцев', 'Олегович', '2000-03-30', '+7545645645', 'Экономика', 0, 'zaytsev@example.com', 5),
(13, 'Ольга', 'Беляева', 'Семеновна', '2000-07-25', '+754654654', 'Экономика', 1, 'belyaeva@example.com', 5),
(14, 'Галина', 'Михайлова', 'Николаевна', '2001-02-11', '+78954545245', 'Экономика', 1, 'mihailova@example.com', 5),
(15, 'Павел', 'Тарасов', 'Алексеевич', '2001-04-15', '+7824824568', 'Экономика', 1, 'tarasov@example.com', 5),
(16, 'Валерия', 'Ковалева', 'Дмитриевна', '2001-08-22', '+7854666545', 'Экономика', 0, 'kovaleva@example.com', 5),
(17, 'Алексей', 'Волков', 'Иванович', '2000-06-14', '+79505762747', 'Информатика', 1, 'volkov@example.com', 9),
(18, 'Юлия', 'Алексеева', 'Сергеевна', '2000-11-07', '+73895461665', 'Информатика', 0, 'alekseeva@example.com', 9),
(19, 'Роман', 'Козлов', 'Дмитриевич', '2001-01-10', '+785461546465', 'Информатика', 1, 'kozlov@example.com', 9),
(20, 'Кирилл', 'Захаров', 'Олегович', '2001-05-08', '+75612131646', 'Информатика', 0, 'zaharov@example.com', 9),
(21, 'Арина', 'Орлова', 'Александровна', '2000-12-20', '+766646646', 'Информатика', 1, 'orlova@example.com', 9);

-- --------------------------------------------------------

--
-- Структура таблицы `student_attendance`
--

CREATE TABLE `student_attendance` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `class_time_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `attended` tinyint(1) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `student_attendance`
--

INSERT INTO `student_attendance` (`id`, `student_id`, `subject_id`, `teacher_id`, `class_time_id`, `date`, `attended`, `group_id`) VALUES
(11, 1, 1, 1, 1, '2024-01-10', 1, 1),
(12, 1, 2, 2, 2, '2024-01-11', 0, 1),
(13, 2, 1, 1, 3, '2024-01-12', 1, 1),
(14, 3, 2, 2, 4, '2024-01-13', 1, 1),
(15, 4, 3, 3, 5, '2024-01-14', 1, 2),
(16, 5, 4, 4, 1, '2024-01-15', 0, 2),
(17, 6, 5, 2, 2, '2024-01-16', 1, 3),
(18, 7, 6, 5, 3, '2024-01-17', 0, 3),
(19, 8, 7, 1, 4, '2024-01-18', 1, 4),
(20, 9, 8, 4, 5, '2024-01-19', 1, 4),
(21, 1, 1, 1, 1, '2024-11-01', 1, 1),
(22, 2, 2, 2, 2, '2024-11-01', 0, 1),
(23, 3, 1, 1, 3, '2024-11-02', 1, 1),
(24, 4, 3, 3, 1, '2024-11-02', 1, 2),
(25, 5, 4, 4, 2, '2024-11-03', 1, 2),
(26, 6, 5, 5, 3, '2024-11-04', 0, 3),
(27, 7, 6, 6, 4, '2024-11-05', 1, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `subjects`
--

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL,
  `subject_name` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `subjects`
--

INSERT INTO `subjects` (`id`, `subject_name`, `direction_id`, `teacher_id`) VALUES
(1, 'Математика', 1, 1),
(2, 'Физика', 1, 2),
(3, 'Чертежи', 1, 3),
(4, 'Экономика', 2, 4),
(5, 'Бухгалтерский учет', 2, 2),
(6, 'Программирование', 3, 5),
(7, 'Алгоритмы', 3, 1),
(8, 'Базы данных', 3, 4),
(9, 'Математика', 1, 1),
(10, 'Физика', 1, 2),
(11, 'Программирование', 1, 3),
(12, 'Экономика', 2, 4),
(13, 'Финансы', 2, 5),
(14, 'История', 3, 1),
(15, 'Литература', 3, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `subject_avg`
--

CREATE TABLE `subject_avg` (
  `subject_id` int(11) NOT NULL DEFAULT '0',
  `avg_grade` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Структура таблицы `teachers`
--

CREATE TABLE `teachers` (
  `id` int(11) NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Дамп данных таблицы `teachers`
--

INSERT INTO `teachers` (`id`, `first_name`, `last_name`, `middle_name`) VALUES
(1, 'Александр', 'Иванов', 'Николаевич'),
(2, 'Марина', 'Петрова', 'Сергеевна'),
(3, 'Олег', 'Сидоров', 'Игоревич'),
(4, 'Анна', 'Кузнецова', 'Владимировна'),
(5, 'Дмитрий', 'Попов', 'Алексеевич'),
(6, 'Андрей', 'Иванов', 'Петрович'),
(7, 'Мария', 'Сидорова', 'Васильевна'),
(8, 'Екатерина', 'Захарова', 'Ивановна'),
(9, 'Дмитрий', 'Смирнов', 'Александрович'),
(10, 'Ольга', 'Павлова', 'Георгиевна');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_address_student` (`student_id`);

--
-- Индексы таблицы `class_times`
--
ALTER TABLE `class_times`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_group_id` (`group_id`);

--
-- Индексы таблицы `direction`
--
ALTER TABLE `direction`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `grades`
--
ALTER TABLE `grades`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_grade_student` (`student_id`),
  ADD KEY `fk_grade_subject` (`subject_id`);

--
-- Индексы таблицы `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_group_direction` (`direction_id`);

--
-- Индексы таблицы `group_avg`
--
ALTER TABLE `group_avg`
  ADD PRIMARY KEY (`group_id`);

--
-- Индексы таблицы `group_subject_avg`
--
ALTER TABLE `group_subject_avg`
  ADD PRIMARY KEY (`group_id`,`subject_id`);

--
-- Индексы таблицы `phones`
--
ALTER TABLE `phones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_phone_student` (`student_id`);

--
-- Индексы таблицы `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_student_group` (`group_id`);

--
-- Индексы таблицы `student_attendance`
--
ALTER TABLE `student_attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_attendance_student` (`student_id`),
  ADD KEY `fk_attendance_subject` (`subject_id`),
  ADD KEY `fk_attendance_teacher` (`teacher_id`),
  ADD KEY `fk_attendance_class_time` (`class_time_id`),
  ADD KEY `fk_attendance_group` (`group_id`);

--
-- Индексы таблицы `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_subject_direction` (`direction_id`),
  ADD KEY `fk_subject_teacher` (`teacher_id`);

--
-- Индексы таблицы `subject_avg`
--
ALTER TABLE `subject_avg`
  ADD PRIMARY KEY (`subject_id`);

--
-- Индексы таблицы `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT для таблицы `class_times`
--
ALTER TABLE `class_times`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT для таблицы `direction`
--
ALTER TABLE `direction`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `grades`
--
ALTER TABLE `grades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT для таблицы `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT для таблицы `phones`
--
ALTER TABLE `phones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT для таблицы `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT для таблицы `student_attendance`
--
ALTER TABLE `student_attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT для таблицы `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `teachers`
--
ALTER TABLE `teachers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `fk_address_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`);

--
-- Ограничения внешнего ключа таблицы `class_times`
--
ALTER TABLE `class_times`
  ADD CONSTRAINT `fk_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`);

--
-- Ограничения внешнего ключа таблицы `grades`
--
ALTER TABLE `grades`
  ADD CONSTRAINT `fk_grade_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`),
  ADD CONSTRAINT `fk_grade_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`);

--
-- Ограничения внешнего ключа таблицы `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `fk_group_direction` FOREIGN KEY (`direction_id`) REFERENCES `direction` (`id`);

--
-- Ограничения внешнего ключа таблицы `phones`
--
ALTER TABLE `phones`
  ADD CONSTRAINT `fk_phone_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`);

--
-- Ограничения внешнего ключа таблицы `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `fk_student_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`);

--
-- Ограничения внешнего ключа таблицы `student_attendance`
--
ALTER TABLE `student_attendance`
  ADD CONSTRAINT `fk_attendance_class_time` FOREIGN KEY (`class_time_id`) REFERENCES `class_times` (`id`),
  ADD CONSTRAINT `fk_attendance_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`),
  ADD CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`),
  ADD CONSTRAINT `fk_attendance_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  ADD CONSTRAINT `fk_attendance_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`);

--
-- Ограничения внешнего ключа таблицы `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `fk_subject_direction` FOREIGN KEY (`direction_id`) REFERENCES `direction` (`id`),
  ADD CONSTRAINT `fk_subject_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
