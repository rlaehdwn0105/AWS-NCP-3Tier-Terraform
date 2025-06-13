#!/bin/bash
# 필요한 패키지들 설치
sudo yum update -y
sudo yum install -y libjpeg* libpng* freetype* gd-* gcc gcc-c++ gdbm-devel
sudo yum install -y httpd*
sudo yum install -y php php-common php-opcache php-cli php-gd php-curl php-mysqlnd php-mysqli

# 웹서버 실행
sudo systemctl enable httpd
sudo systemctl start httpd

# 간단한 웹페이지 생성
# 로드밸런서 동작 확인을 위한 페이지
sudo sh -c 'echo "<?php echo \"Terraform Tutorial \" . gethostname(); ?>" > /var/www/html/index.php'
# php 동작 확인을 위한 페이지
sudo sh -c 'echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php'

# db 연동을 확인하기 위한 간단한 웹페이지
# 웹 서버 기본 루트 페이지 수정을 하기 위해 /var/www 디렉토리의 소유권 및 권한을 변경
sudo groupadd www
sudo usermod -aG www ec2-user
# /var/www 의 그룹 소유권을 www 그룹으로 변경
# /var/www 와 하위 디렉토리에 그룹 쓰기 권한을 추가하고, 나중에 생성될 하위 디렉토리에서 GID 설정
# /var/www 및 하위 디렉토리의 파일 권한을 변경
sudo chown -R root:www /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} +
find /var/www -type f -exec sudo chmod 0664 {} +

# /var/www 에 inc 디렉토리 생성
cd /var/www
mkdir inc
cd inc
# 연동을 위한 dbinfo 작성
cat << EOF > dbinfo.inc
<?php
define('DB_SERVER', '${db_address}');
# RDS의 라이터 엔드포인트
define('DB_USERNAME', 'admin');
define('DB_PASSWORD', 'testtest');
define('DB_DATABASE', 'djdb');
# RDS 생성할때 만든 Data Base 이름
?>
EOF

# html 디렉토리로 이동
cd /var/www/html
# samplepage.php 작성
cat << 'EOF' > samplepage.php
<?php include "../inc/dbinfo.inc"; ?>
<html>
<body>
<h1>Sample page</h1>
<?php
/* Connect to MySQL and select the database. */
$connection = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD);
if(mysqli_connect_errno()) echo "Failed to connect to MySQL: " . mysqli_connect_error();
$database = mysqli_select_db($connection, DB_DATABASE);
/* Ensure that the Employees table exists. */
VerifyEmployeesTable($connection, DB_DATABASE);
/* If input fields are populated, add a row to the Employees table. */
$employee_name = htmlentities($_POST['Name']);
$employee_address = htmlentities($_POST['Address']);
if(strlen($employee_name) || strlen($employee_address)) {
    AddEmployee($connection, $employee_name, $employee_address);
}
?>
<!-- Input form -->
<form action="<?PHP echo $_SERVER['SCRIPT_NAME'] ?>" method="POST">
    <table border="0">
        <tr>
            <td>Name</td>
            <td>Address</td>
        </tr>
        <tr>
            <td>
                <input type="text" name="Name" maxlength="45" size="30" />
            </td>
            <td>
                <input type="text" name="Address" maxlength="90" size="60" />
            </td>
            <td>
                <input type="submit" value="Add Data" />
            </td>
        </tr>
    </table>
</form>
<!-- Display table data. -->
<table border="1" cellpadding="2" cellspacing="2">
    <tr>
        <td>ID</td>
        <td>Name</td>
        <td>Address</td>
    </tr>
    <?php
    $result = mysqli_query($connection, "SELECT * FROM Employees");
    while($query_data = mysqli_fetch_row($result)) {
        echo "<tr>";
        echo "<td>",$query_data[0], "</td>",
        "<td>",$query_data[1], "</td>",
        "<td>",$query_data[2], "</td>";
        echo "</tr>";
    }
    ?>
</table>
<!-- Clean up. -->
<?php
mysqli_free_result($result);
mysqli_close($connection);
?>
</body>
</html>
<?php
/* Add an employee to the table. */
function AddEmployee($connection, $name, $address) {
    $n = mysqli_real_escape_string($connection, $name);
    $a = mysqli_real_escape_string($connection, $address);
    $query = "INSERT INTO `Employees`(`Name`, `Address`) VALUES('$n', '$a');";
    if(!mysqli_query($connection, $query)) echo("<p>Error adding employee data.</p>");
}
/* Check whether the table exists and, if not, create it. */
function VerifyEmployeesTable($connection, $dbName) {
    if(!TableExists("Employees", $connection, $dbName)) {
        $query = "CREATE TABLE `Employees`(
            `ID` int(11) NOT NULL AUTO_INCREMENT,
            `Name` varchar(45) DEFAULT NULL,
            `Address` varchar(90) DEFAULT NULL,
            PRIMARY KEY(`ID`),
            UNIQUE KEY `ID_UNIQUE`(`ID`)
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1";
        if(!mysqli_query($connection, $query)) echo("<p>Error creating table.</p>");
    }
}
/* Check for the existence of a table. */
function TableExists($tableName, $connection, $dbName) {
    $t = mysqli_real_escape_string($connection, $tableName);
    $d = mysqli_real_escape_string($connection, $dbName);
    $checktable = mysqli_query($connection,
    "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_NAME = '$t' AND TABLE_SCHEMA = '$d'");
    if(mysqli_num_rows($checktable)> 0) return true;
    return false;
}
?>
EOF

sudo chmod 666 /var/www/html/samplepage.php
