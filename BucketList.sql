-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2
-- http://www.phpmyadmin.net
--
-- Host: localhost:3306
-- Generation Time: May 27, 2018 at 12:21 PM
-- Server version: 5.7.22-0ubuntu0.16.04.1
-- PHP Version: 7.0.30-0ubuntu0.16.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `BucketList`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddUpdateLikes` (IN `p_wish_id` INT, IN `p_user_id` INT, IN `p_like` INT)  BEGIN
    if (select exists (select 1 from tbl_likes where wish_id = p_wish_id and user_id = p_user_id)) then
 
        update tbl_likes set wish_like = p_like where wish_id = p_wish_id and user_id = p_user_id;
         
    else
         
        insert into tbl_likes(
            wish_id,
            user_id,
            wish_like
        )
        values(
            p_wish_id,
            p_user_id,
            p_like
        );
 
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addWish` (IN `p_title` VARCHAR(45), IN `p_description` VARCHAR(1000), IN `p_user_id` BIGINT, IN `p_file_path` VARCHAR(200), IN `p_is_private` INT, IN `p_is_done` INT, IN `p_link` VARCHAR(200), IN `p_tags` VARCHAR(200), IN `p_block` VARCHAR(200), IN `p_IPFS` VARCHAR(200))  BEGIN
    insert into tbl_wish(
        wish_title,
        wish_description,
        wish_user_id,
        wish_date,
        wish_file_path,
        wish_private,
        wish_accomplished,
        wish_link,
        wish_tags,
        wish_block,
        wish_IPFS
    )
    values
    (
        p_title,
        p_description,
        p_user_id,
        NOW(),
        p_file_path,
        p_is_private,
        p_is_done,
        p_link,
        p_tags,
        p_block,
        p_IPFS
    );
     SET @last_id = LAST_INSERT_ID();
    insert into tbl_likes(
        wish_id,
        user_id,
        wish_like
    )
    values(
        @last_id,
        p_user_id,
        0
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUser` (IN `p_name` VARCHAR(20), IN `p_username` VARCHAR(20), IN `p_password` VARCHAR(600))  BEGIN
    if ( select exists (select 1 from tbl_user where user_username = p_username) ) THEN
     
        select 'Username Exists !!';
     
    ELSE
     
        insert into tbl_user
        (
            user_name,
            user_username,
            user_password
        )
        values
        (
            p_name,
            p_username,
            p_password
        );
     
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_deleteWish` (IN `p_wish_id` BIGINT, IN `p_user_id` BIGINT)  BEGIN
delete from tbl_wish where wish_id = p_wish_id and wish_user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllWishes` ()  BEGIN
select wish_id,wish_title,wish_description,wish_file_path,wish_link,wish_tags,wish_block,wish_IPFS,getSum(wish_id) from tbl_wish where wish_private = 0
ORDER by getSum(wish_id) DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getLikeStatus` (IN `p_wish_id` INT, IN `p_user_id` INT)  BEGIN
    select getSum(p_wish_id),hasLiked(p_wish_id,p_user_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetWishById` (IN `p_wish_id` BIGINT, IN `p_user_id` BIGINT)  BEGIN
select wish_id,wish_title,wish_description,wish_file_path,wish_private,wish_accomplished,wish_link,wish_tags,wish_block,wish_IPFS from tbl_wish where wish_id = p_wish_id and wish_user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetWishByUser` (IN `p_user_id` BIGINT, IN `p_limit` INT, IN `p_offset` INT, OUT `p_total` BIGINT)  BEGIN
     
    select count(*) into p_total from tbl_wish where wish_user_id = p_user_id;
 
    SET @t1 = CONCAT( 'select * from tbl_wish where wish_user_id = ', p_user_id, ' order by wish_date desc limit ',p_limit,' offset ',p_offset);
    PREPARE stmt FROM @t1;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateWish` (IN `p_title` VARCHAR(45), IN `p_description` VARCHAR(1000), IN `p_wish_id` BIGINT, IN `p_user_id` BIGINT, IN `p_file_path` VARCHAR(200), IN `p_is_private` INT, IN `p_is_done` INT, IN `p_link` VARCHAR(200), IN `p_tags` VARCHAR(200), IN `p_block` VARCHAR(200), IN `p_IPFS` VARCHAR(200))  BEGIN
update tbl_wish set
    wish_title = p_title,
    wish_description = p_description,
    wish_file_path = p_file_path,
    wish_private = p_is_private,
    wish_accomplished = p_is_done,
    wish_link = p_link,
    wish_tags = p_tags,
    wish_block = p_block,
    wish_IPFS = p_IPFS
  
    where wish_id = p_wish_id and wish_user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validateLogin` (IN `p_username` VARCHAR(20))  BEGIN
    select * from tbl_user where user_username = p_username;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getSum` (`p_wish_id` INT(11)) RETURNS INT(11) BEGIN
select sum(wish_like) into @sm from tbl_likes where wish_id = p_wish_id;
RETURN @sm;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hasLiked` (`p_wish` INT, `p_user` INT) RETURNS INT(11) BEGIN
     
    select wish_like into @myval from tbl_likes where wish_id =  p_wish and user_id = p_user;
RETURN @myval;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_likes`
--

CREATE TABLE `tbl_likes` (
  `wish_id` int(11) NOT NULL,
  `like_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `wish_like` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_likes`
--

INSERT INTO `tbl_likes` (`wish_id`, `like_id`, `user_id`, `wish_like`) VALUES
(21, 23, 19, 1),
(22, 24, 19, 0),
(23, 25, 19, 1),
(24, 26, 19, 1),
(25, 27, 20, 1),
(22, 28, 20, 1),
(23, 29, 20, 1),
(24, 30, 20, 1),
(21, 31, 20, 1),
(25, 32, 19, 1),
(26, 33, 21, 0),
(27, 34, 21, 1),
(28, 35, 19, 0),
(27, 36, 20, 1),
(27, 37, 19, 1),
(23, 38, 21, 1),
(29, 39, 21, 0),
(30, 40, 21, 0),
(31, 41, 24, 0),
(32, 42, 24, 0),
(33, 43, 19, 1),
(33, 44, 21, 1),
(33, 45, 20, 1),
(33, 46, 24, 1),
(34, 47, 19, 0);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user`
--

CREATE TABLE `tbl_user` (
  `user_id` bigint(20) NOT NULL,
  `user_name` varchar(45) DEFAULT NULL,
  `user_username` varchar(45) DEFAULT NULL,
  `user_password` varchar(600) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_user`
--

INSERT INTO `tbl_user` (`user_id`, `user_name`, `user_username`, `user_password`) VALUES
(19, 'test', 'test@test.com', 'pbkdf2:sha256:50000$U8QxENxS$e6a9d497cfe6c6ffd88920fe304eccde509d88288cc1bdd636379f23e51a3c9d'),
(20, 'best', 'best@test.com', 'pbkdf2:sha256:50000$Ft6yE4Uf$997254295723aef3c130b1dd7bdd6e7550b2ea5bd2a32d8532c6238864fd3ce5'),
(21, 'rest', 'rest@rest.com', 'pbkdf2:sha256:50000$P58nkD31$e77e7e37d01ac856e319d19cb96961bfebce36c458efac24a6b90ca005d74daf'),
(22, 'yest', 'yest@test.com', 'pbkdf2:sha256:50000$nqGHZSFp$9e8596f059793f38c6e02d714c42e39ebbec77adb55836266f72869f0297b19a'),
(23, 'aest', 'aest@aest.com', 'pbkdf2:sha256:50000$ow1qozMn$24a5962c7cb8a21524bc5b47fff5939fdc205202a39b00a51efa5fea7c44c9ce'),
(24, 'vest', 'vest@test.com', 'pbkdf2:sha256:50000$hXueAjDZ$1cbc874bf03ed776d94e573095c2900aa44abb3150dd50a4b92f8234c535fa3e');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_wish`
--

CREATE TABLE `tbl_wish` (
  `wish_id` int(11) NOT NULL,
  `wish_title` varchar(47) DEFAULT NULL,
  `wish_description` varchar(5000) DEFAULT NULL,
  `wish_like` int(11) DEFAULT '0',
  `wish_user_id` int(11) DEFAULT NULL,
  `wish_date` datetime DEFAULT NULL,
  `wish_file_path` varchar(200) DEFAULT NULL,
  `wish_accomplished` int(11) DEFAULT '0',
  `wish_private` int(11) DEFAULT '0',
  `wish_link` varchar(200) DEFAULT NULL,
  `wish_tags` varchar(200) DEFAULT NULL,
  `wish_block` varchar(200) DEFAULT '195EEjD1rPpe7ws8L6Xirwrgqsmo7qy1zr',
  `wish_IPFS` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_wish`
--

INSERT INTO `tbl_wish` (`wish_id`, `wish_title`, `wish_description`, `wish_like`, `wish_user_id`, `wish_date`, `wish_file_path`, `wish_accomplished`, `wish_private`, `wish_link`, `wish_tags`, `wish_block`, `wish_IPFS`) VALUES
(23, 'iptables linux', 'table definition for port 80', 0, 19, '2018-05-25 23:01:35', 'static/Uploads/5a31a6ab-4090-4a95-94d8-6743b08bdba8.png', 0, 0, 'static/Uploads/5a31a6ab-4090-4a95-94d8-6743b08bdba8.png', 'tag1 ', '195EEjD1rPpe7ws8L6Xirwrgqsmo7qy1zr', '195EEjD1rPpe7ws8L6Xirwrgqsmo7qy1zr'),
(27, 'So You Want to Build a Chat Bot', 'So You Want to Build a Chat Bot', 0, 21, '2018-05-26 08:01:13', 'static/Uploads/d8a2acca-d701-4704-98a8-3ace233f3564.png', 0, 0, 'static/Uploads/d8a2acca-d701-4704-98a8-3ace233f3564.png', 'asf asf', '195EEjD1rPpe7ws8L6Xirwrgqsmo7qy1zr', '195EEjD1rPpe7ws8L6Xirwrgqsmo7qy1zr'),
(29, '4 steps to troubleshooting', '4 steps to troubleshooting (almost) any IT issue', 0, 21, '2018-05-26 11:18:44', 'static/Uploads/38a85e05-e1cc-4330-966d-43adc6e6a345.png', 0, 0, 'https://www.spiceworks.com/it-articles/troubleshooting-steps/', '', '', '38a85e05-e1cc-4330-966d-43adc6e6a345'),
(33, 'TRIPBIT (TBT)', 'The New Global Currency for Travel and Tourism', 0, 19, '2018-05-26 15:09:55', 'static/Uploads/50897163-803d-46bc-b4af-7344d7c57a3d.png', 0, 0, 'https://icoindex.com/profile/tripbit-tbt', 'TRIPBIT', 'a', 'a');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_likes`
--
ALTER TABLE `tbl_likes`
  ADD PRIMARY KEY (`like_id`);

--
-- Indexes for table `tbl_user`
--
ALTER TABLE `tbl_user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id_3` (`user_id`),
  ADD UNIQUE KEY `user_password` (`user_password`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `user_id_2` (`user_id`),
  ADD KEY `user_id_4` (`user_id`),
  ADD KEY `user_id_5` (`user_id`);

--
-- Indexes for table `tbl_wish`
--
ALTER TABLE `tbl_wish`
  ADD PRIMARY KEY (`wish_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_likes`
--
ALTER TABLE `tbl_likes`
  MODIFY `like_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;
--
-- AUTO_INCREMENT for table `tbl_user`
--
ALTER TABLE `tbl_user`
  MODIFY `user_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `tbl_wish`
--
ALTER TABLE `tbl_wish`
  MODIFY `wish_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
