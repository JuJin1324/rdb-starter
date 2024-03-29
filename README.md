# rdb-starter

## set 과 multiset
### set
> 중복을 허용하지 않는 유일한 원소만 가질 수 있는 자료구조이다.

### multiset
> 중복을 허용하는 set 이다.

---

## DDL(Data Definition Language)
### 실시간 테이블 스키마 변경
> MySQL 8.0 이후 버전에서는 테이블 스키마를 다운 타임 없이 실시간으로 변경할 수 있는 기능을 제공  
> `ALTER TABLE table_name [alter_specification], ALGORITHM=INSTANT;`  
> 기존 alter table 쿼리 뒤에 `, ALGORITHM=INSTANT` 를 붙이면 실시간으로 스키마 변경이 가능해짐.   
> 참조사이트: [MySQL 8.0: InnoDB now supports Instant ADD COLUMN](https://dev.mysql.com/blog-archive/mysql-8-0-innodb-now-supports-instant-add-column/)  

---

## Constraint
### Foreign key constraint
> `on delete cascade`: 부모 테이블 tuple 삭제 시 연결된 자식 테이블의 tuple 도 삭제    
> `on update cascade`: 부모 테이블 tuple 의 primary key 수정시 자식 테이블 tuple 의 foreign key 도 같이 업데이트   
> `on delete set null` / `on update set null`: 부모 테이블 tuple 수정/삭제 시 자식 테이블 tuple 의 foreign key 가 null 로 변경됨      
> `on delete restrict` / `on update restrict`: 부모 테이블의 tuple 이 수정되는 것을 불가    
> `on delete no action` / `on update no action`: restrict 와 동일, 옵션을 지정안할 시 자동으로 선택됨    
> `on delete set default` / `on update set default`: 부모 테이블 tuple 의 수정/삭제 시 자식 테이블 tuple 의 foreign key 를 default 값으로 업데이트

---

## DML(Data Manipulation Language)
### like
> `%`: 0~N 개의 문자 검색  
> ex) `nickname like '%동%'` => 결과 값으로 땡땡땡동땡 과 같이 앞뒤로 붙는 글자가 0개 ~ N개가 될 수 있음.
> 
> `_`: 1개의 문자 검색  
> ex) `nickname like '_동_'` => 결과 값으로 문동은 과 같이 1글자만 대응됨.  

### exists
> 서브쿼리가 반환하는 결과값이 있는지를 조사한다.
> 단지 반환된 행이 있는지 없는지만 보고 값이 있으면 참 없으면 거짓을 반환한다.
>
> 한 테이블이 다른 테이블과 외래키(FK)를 통한 관계가 있을 때 유용  
> 조건에 해당하는 ROW 의 존재 유무만 판단하고 이후 더 추가 로직을 수행하지 않음(지연 평가 원리 이기 때문에 성능이 좋다).  
> 일반적으로 SELECT 절까지 가지 않기에 IN에 비해 속도나 성능면에서 더 좋음
> 
> 반대로 조건에 맞지 않는 ROW 만 추출하고 싶으면 NOT EXISTS  
> 쿼리 순서 : 메인 쿼리 → EXISTS 쿼리  
> 
> 예시: 주문한 적이 있는(주문이 존재하는) 사용자를 알고 싶은 경우
> ```sql
> select * from customer c
> where exists(
>   select * from orders o where o.customer_id = c.id
> );
> ```
> 
> in 으로 변경 예시
> ```sql
> select * from customer c where c.id in (select customer_id from orders);
> ```
> select 절에서 조회한 컬럼 값으로 비교하기 때문에 exists 에 비해 성능이 떨어지지만 최신 버전의 DBMS 의 경우 성능차이가 크지 않음.   

### not exists
> 조건에 맞지 않는 레코드만 추출하는 옵션  
> 예시: 주문을 한 적이 없는 사용자를 알고 싶은 경우  
> ```sql
> select * from customer c
> where not exists(
>   select * from orders o where o.customer_id = c.id
> )
> ```
> 
> not in 으로 변경 예시
> ```sql
> select * from customer c where c.id not in (select customer_id from orders);
> ```

### 참조사이트
> [서브쿼리 연산자 EXISTS 총정리 성능 비교](https://inpa.tistory.com/entry/MYSQL-%F0%9F%93%9A-%EC%84%9C%EB%B8%8C%EC%BF%BC%EB%A6%AC-%EC%97%B0%EC%82%B0%EC%9E%90-EXISTS-%EC%B4%9D%EC%A0%95%EB%A6%AC-%EC%84%B1%EB%8A%A5-%EB%B9%84%EA%B5%90)

### three valued logic
> DB 의 연산 결과는 3가지가 존재한다. `true`, `false`, `unknown`  
> null 은 상태가 정해지지 않은 값을 의미함으로 null 과 관련된 연산에서 보통 결과 값이 unknown 으로 나오게 된다.    
> true and null => unknown    
> true or null => true  
> false and null => false  
> false or null => unknown  
> null and null => unknown  
> null or null => unknown  

### group by
> group by 뒤에 애트리뷰트가 2개 이상 올 수 있다. 하나의 애트리뷰트로만 group by 를 할 수 있지만 추가적으로 애트리뷰트 2개 이상으로도 가능하다.  
> order by 처럼 선행 후행 방식이 아닌 2개 이상의 애트리뷰트를 조합해서 group by 된다.  
> 예를 들어 GROUP BY 성별, 지역 이라고 했을 때에, 경기도 여성 / 경기도 남성 / 서울 여성 / 서울 남성 이런 식으로 성별과 지역을 이용해 만들 수 있는 
> 모든 경우의 수로 그룹을 만들수 있게 된다.  
> 
> 참조사이트: [group by에 두 개 이상의 column을 쓰는 경우](https://www.inflearn.com/questions/27971/group-by%EC%97%90-%EB%91%90-%EA%B0%9C-%EC%9D%B4%EC%83%81%EC%9D%98-column%EC%9D%84-%EC%93%B0%EB%8A%94-%EA%B2%BD%EC%9A%B0) 

### group by - having
> group by 뒤에 having 키워드는 group by 된 결과를 기반으로 추가 조건을 줘서 필터링하는 것.  
> 즉 group by 이전에 where 로 필터가 되고 where 와 group by 가 실행된 후에 그 결과를 having 절에서 추가 필터링하는 개념.

---

## join
### inner join
> inner join 의 경우 join condition 이 true 인 경우의 tuple 만 반환  
> 예를 들어 employee 테이블과 department 테이블이 inner join 을 할 때 employee tuple 에 foreign key 인 dept_id 가 null 인 경우 해당 tuple 의 
> 결과 값이 unknown 이기 때문에 결과 ROW 에 나오지 않는다.  

---

## Transaction
### Auto commit 설정
> MySQL 기준 Auto commit 설정 확인 쿼리: `select @@AUTOCOMMIT;`  
> 결과가 '1'인 경우: 자동 Auto commit 활성화 상태.   
> 결과가 '0'인 경우: 자동 Auto commit 비활성화 상태, 수동 커밋 필요.
>
> Auto commit 설정 활성화 쿼리: `SET autocommit=1;`  
> Auto commit 설정 비활성화 쿼리: `SET autocommit=0;`

### ACID
> 트랜잭션의 속성을 정의해놓은 것.  
> Atomicity(원자성): 트랜잭션에 묶인 쿼리가 모두 성공하지 않고 중간에 하나라도 쿼리가 실패하면 트랜잭션 내에서 실행되었던 쿼리를 전부 롤백시키는 것.  
> Consistency(일관성): DB 의 제약사항(constraint) 위반시 트랜잭션을 롤백시키는 것.  
> Isolation(격리성): 여러 트랜잭션들이 동시에 실행될 때도 혼자 실행되는 것처럼 동작하게 만드는 것. DBMS 는 여러 종류의 Isolation level 을 제공.  
> Durability(영구성): 커밋된 트랜잭션은 DB에 영구적으로 저장되는 것.

---

## Isolation level
> 격리 수준

### READ UNCOMMITTED
> 단어 그대로 Update 후 commit 되지 않은 데이터를 다른 트랜잭션에서 읽을 수 있는 격리 수준.  
> Dirty read 현상 발생: Update 후 commit 되지 않은 데이터를 다른 트랜잭션에서 읽을 수 있는 현상

### READ COMMITTED
> RDB 에서 대부분 기본적으로 사용되고 있는 격리 수준(oracle 은 READ COMMITTED, mysql InnoDB 엔진의 경우 REPEATABLE READ)  
> Dirty read 현상은 발생하지 않음. 트랜잭션에서는 row 조회 시 commit 된 row 만 조회
>
> 문제: A 트랜잭션이 1번 row 를 조회하고 로직을 진행하다가 B 트랜잭션에서 1번 row 를 Update 후 commit 을 한다.
> 그 후 끝나지 않은 A 트랜잭션에서 다시 1번 row 를 조회하면 업데이트된 1번 row 가 조회된다. 결과적으로 동일 트랜잭션 내에서 동일한 row 를 조회하는데
> 결과가 달라질 수 있는 문제가 발생할 수 있음.
>
> 또한 Lost update 가 발생할 수 있다.

### REPEATABLE READ
> 트랜잭션이 시작되기 전에 커밋된 내용에 대해서만 조회할 수 있는 격리 수준이다.  
> 각 트랜잭션에 ID 를 부여해서 트랜잭션 ID 보다 작은 트랜잭션 번호에서 변경한 정보로 조회한다.
> 각 트랜잭션 ID 에서 변경한 정보가 Undo 공간에 적재되서 다른 트랜잭션에서 row 조회 시에 Undo 공간에 적재된 row 를 조회한다.
>
> 위의 `READ COMMITTED` 에서 발생한 문제를 `REPEATABLE READ` 에 대입해보면 다음과 같다.  
> 문제: A 트랜잭션이 1번 row 를 조회하고 로직을 진행하다가 B 트랜잭션에서 1번 row 를 Update 후 commit 을 한다.
> 그 후 끝나지 않은 A 트랜잭션에서 다시 1번 row 를 조회하면 Undo 공간에 적재된 1번 row 가 조회된다.  
> 결과적으로 B 트랜잭션의 ID 가 A 트랜잭션 ID 이후이기 때문에 A 트랜잭션에서는 B 트랜잭션의 변경 내용을 읽지 않는다.
>
> REPEATABLE READ 에서 발생할 수 있는 데이터 부정합  
> 1.UPDATE 부정합  
> 트랜잭션 A 에서 트랜잭션 시작 후 트랜잭션 B 에서 `update member set name='2' where name='1'` 의 쿼리를 실행 후 커밋한다.    
> 아직 끝나지 않은 트랜잭션 A 에서 `update member set name='3' where name='1'` 의 쿼리를 실행하면 아무 변경이 일어나지 않는다.  
> 트랜잭션 A 에서 name='1' 은 조회는 가능하지만 업데이트를 Undo 영역을 통해서 동시성을 해결할 수는 없다.  
> 다만 해당 예시를 보면 where 구문의 name 칼럼이 아닌 ID(Primary Key) 칼럼을 통해서 변하지 않는 값을 where 구문으로 조건을 주게되면
> 트랜잭션 A 에서 Update 시에도 Update 가 유효하다.
>
> 2.Phantom READ  
> 트랜잭션 A 가 시작되고 트랜잭션 B 에서 row 를 1개 Insert 하고 커밋한다. 그 후 트랜잭션 A 에서 트랜잭션 B 에서 Insert 한 row 를 조회하려해도
> 조회되지 않는다(여기까지는 정상). 하지만 트랜잭션 A 에서 조회되지 않았던 row 의 ID 로 Update 문을 실행하면 Update 가 정상적으로 진행되며,
> 이후부터 해당 row 의 ID 로 조회를 시도하려 하면 조회가 되버린다.  
> mySQL 의 InnoDB 엔진에서는 REPEATABLE READ 에서도 Phantom READ 가 발생하지 않는다.
>
> Lost update 방지  
> PostgreSQL 의 REPEATABLE READ 에서는 같은 데이터에 먼저 update 한 트랜잭션이 commit 되면
> 나중 트랜잭션은 rollback 되게하여 Lost update 를 방지한다.
>
> MySQL 의 REPEATABLE READ 에서는 Lost update 를 방지하기 위해서 Locking read 를 통해서 read 시에도 write-lock 을 건다.  
> write-lock 을 건 이후 commit 을 통해서 unlock 후 다른 트랜잭션에서 해당 데이터를 read 하게되면 `locking read 는 가장 최근의
> commit 된 데이터를 읽는다.`이기 때문에 lost update 가 방지된다.
>

### SERIALIZABLE
> InnoDB 에서 기본적으로 순수한 SELECT 작업은 아무런 잠금을 걸지않고 동작하는데,  
> 격리수준이 SERIALIZABLE일 경우 읽기 작업에도 공유 잠금을 설정하게 되고, 이러면 동시에 다른 트랜잭션에서 이 레코드를 변경하지 못하게 된다.  
> 이러한 특성 때문에 동시처리 능력이 다른 격리수준보다 떨어지고, 성능저하가 발생하게 된다.

### 참조사이트
> [[db] 트랜잭션 격리 수준(isolation level)](https://joont92.github.io/db/%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B2%A9%EB%A6%AC-%EC%88%98%EC%A4%80-isolation-level/)
> [DB 트랜잭션 isolation 속성과 lost update](https://easy-code-yo.tistory.com/38)

---

## Concurrency control
### write-lock(exclusive lock)
> 데이터를 read/write 할 때 사용한다.  
> 다른 tx 가 같은 데이터를 read/write 하는 것을 허용하지 않는다.

### read-lock(shared lock)
> 데이터를 read 할 때 사용한다.  
> 다른 tx 가 같은 데이터를 read 하는 것은 허용한다. write 는 허용하지 않는다.

### 2PL protocol(two-phase locking)
> tx 에서 모든 locking operation 이 최초의 unlock operation 보다 먼저 수행되도록 하는 것.
> 트랜잭션 내에서 먼저 처음에 필요한 락을 모두 획득 후 쿼리를 진행 후에 필요 없어진 락들을 차례차례 unlock 하는 방식.
>
> Expanding phase: 처음이 필요한 락을 모두 획득하는 phase  
> Shrinking phase: 처음에 취득한 lock 들을 반환만 하고 취득하지 않는 phase  
> 이 2개의 phase 를 사용하는 방식이 2PL protocol(two-phase locking) 이다.

---

## MVCC
### 등장 배경
> MVCC 이전에는 동시성 처리를 위해서 lock 및 2PL protocol 을 통해서 해결하려함.  
> read-lock 은 다른 트랜잭션에서 데이터를 read-lock 하는 것을 허용하지만 그 외에 write-lock 은 다른 트랜잭션에서 데이터를
> write-lock 하는 것을 허용하지 않음.   
> write-lock 과 write-lock 은 동시성을 처리할 수 없음이 자명함. 하지만 read-lock 과 write-lock 을 동시에 못하게 하고
> read-lock 과 read-lock 만 동시성 처리가 가능하게 하면 동시성 처리가 너무 안됨.
>
> MVCC의 주 목적은 Lock을 사용하지 않는 일관된 읽기를 제공하는 것이다.  
> Lock을 사용하지 않는 이유는, 베타적 락으로 인해 다른 트랜잭션이 해당 데이터를 read하기 위해 기다리는 상황이 발생하고, 이런 트랜잭션들이 증가한다면 성능 저하로 이어지기 때문이다.  
> 궁극적인 목적은 Lock을 사용하지 않음으로써 성능을 향상시키기 위함이다.  
> 참조사이트: [MySQL MVCC란?](https://velog.io/@znftm97/MySQL-MVCC%EB%9E%80)

### 특징 - 공통
> 1.조회 시 commit 된 상태의 데이터로 조회한다.  
> 2.마지막 데이터만 읽는 것이 아닌 특정 시점의 데이터를 읽을 수 있기 때문에 MVCC 는 데이터 변화(write한 데이터) 이력을 관리한다.    
> 3.read 와 write 는 서로를 block 하지 않는다.

### READ COMMITTED
> 1.MVCC 는 isolation level 을 기준으로 가장 최근에 commit 된 데이터를 읽는다.    
> READ COMMITTED 의 경우 tx 시점과 상관 없이 commit 된 데이터로 읽는다.   
> 그렇기 때문에 2개 이상의 tx 에서 동일 데이터를 조회한 후 서로 업데이트할 경우 한쪽의 Update 가 사라지는 Lost Update 가 발생할 수 있다.

### REPEATABLE READ
> REPEATABLE READ 의 경우 tx 시작 전에 commit 된 데이터만 읽는다.
>
> PostgreSQL 기준으로 2개 이상의 tx 에서 동일 데이터를 조회한 후 서로 업데이트할 경우 먼저 업데이트한 tx 가 commit 한 경우
> 다음 tx 가 commit 하려하면 다음 tx 는 rollback 되서 Lost Update 를 방지한다.
>
> MySQL 기준으로 2개 이상의 tx 에서 동일 데이터를 조회한 후 서로 업데이트할 경우 먼저 업데이트한 tx 가 commit 한 경우
> 다음 tx 가 commit 하려하면 다음 tx 는 그대로 commit 이 되서 Lost Update 가 그대로 발생한다.  
> MySQL 은 MVCC + REPEATABLE READ 만으로는 Lost Update 를 막을 수 없으며 그래서 MySQL 에서는 Lost Update 방지를 위해서 추가적으로
> Locking read 를 사용한다.

### Locking read
> locking read 는 DBMS 내부에서 설정으로 자동 동작하는 것이 아닌 조회 시 개발자가 select 문의 끝에 `for update` 혹은 `for share` 와 같은
> 문장을 기재해서 lock 을 걸어서 동작한다. (여기서 lock 은 Record lock 을 뜻한다)
> MySQL 에서는 MVCC + REPEATABLE READ 만으로는 Lost Update 를 막을 수 없었다.
> 하지만 locking read 를 통해서 조회 시 `for update` 를 통해서 write lock 걸어서 2개 이상의 tx 에서 조회 후 데이터 수정이 있었다고 가정해보자.
> 두 tx 중 먼저 write lock 을 획득한 tx 에서는 로직이 수행되고 write lock 을 획득하지 못한 tx 는 대기상태가 된다.
> 먼저 lock 획득한 tx 가 commit 한 후 다음 tx 가 대기상태가 풀려서 해당 데이터를 write lock 걸어서 조회하면 이전 tx 에서 commit 되어 수정된 데이터가 조회된다.
>
> 그러니까 MySQL 에서 REPEATABLE READ 사용 시 발생할 수 있는 Lost Update 문제를 한 tx 가 write lock 을 걸면 다른 tx 에서 write lock 걸어서 조회하려할 때
> 대기상태로 두는 방식으로 Lost Update 를 대응하고, PostgreSQL 은 lock 을 걸지 않고 두 tx 가 동일 데이터를 조회할 때 한 tx 에서 먼저 수정 후 commit 해버리면
> 다음 tx 에서는 rollback 을 시켜버리는 방식으로 Lost Update 를 대응했다.  
> 주의점은 PostgreSQL 에서 locking read 를 사용하여 2개 이상의 tx 에서 동일 데이터에 write lock 걸어서 조회하는 경우,
> 먼저 lock 을 획득한 tx 에서 수정 후 commit 한 후에 다음 tx 에서 대기상태 후 write lock 을 걸어서 조회하려하면 rollback 이 수행된다.  
> 즉 PostgreSQL 은 locking read 를 걸든 안걸든 MVCC + REPEATABLE READ 가 동작하는 방식이 동일하다.
>
> **종류**  
> write-lock: `select ... for update`  
> 조회 시 뒤에 `for update` 를 기재하여 다른 tx 에서는 read-lock 및 write-lock 를 모두 걸 수 없도록 write-lock 을 건다.  
> MySQL 에서 Lost update 를 방지하기 위한 write-lock 은 update 하는 row 의 특정 칼럼이 증감 연산을 하여 update 가 누락되지 않고 모두 수행되어야
> 하는 경우에 유용하다. 
> 예시 1) 메시징 서비스에서 메시지 읽음 처리를 통해서 unreadCount 를 감소시키는 update 쿼리 연산  
> 예시 2) 송금과 출금 서비스  
>
> read-lock: `select ... for share`  
> 조회 시 뒤에 `for share` 를 기재하여 다른 tx 에서는 read-lock 만 걸 수 있도록 read-lock 을 건다.  

---

## Index
### 특징
> 조회 속도의 향상 및 시스템 부하를 줄여, 시스템 전체 성능 향상을 위해서 사용한다.  
> 하지만 index 를 위한 추가 저장 공간이 필요하고 데이터가 많이 있다면 생성에 많은 시간이 걸린다.  
> INSERT, UPDATE, DELETE 와 같이 조회 외에 데이터 업데이트가 자주 발생하면 성능이 많이 하락할 수 있다.  

### 사용되는 곳
> 1.where 조건 시 full-scan 이 아닌 인덱스 스캔으로 빠르게 조회.  
> 2.order by 및 group by 시 빠른 처리.

### Primary key
> Primary key 에는 따로 인덱스를 따로 생성할 필요 없이 RDBMS 에서 자동 생성해준다.

### Foreign key
> Foreign key 에는 MySQL 사용 시 인덱스를 따로 생성할 필요 없이 RDBMS 에서 자동 생성해준다.

### 쿼리
> 테이블 별 인덱스 조회: `show index from <테이블명>`  
> 인덱스 생성: `create index <인덱스명> on <테이블명> ( 칼럼명1, 칼럼명2, ... );`  
> 유니크 인덱스 생성: `create unique index <인덱스명> on <테이블명> ( 칼럼명1, 칼럼명2, ... );`

### Multi-column index
> 멀티 컬럼 인덱스 생성 시 가장 왼쪽의 인덱스부터 기준으로 삼아서 인덱스가 정렬된다.  
> 예를 들어서 인덱스에 a, b 칼럼으로 멀티 칼럼 인덱스를 생성 시 왼쪽인 a 칼럼을 우선으로 정렬이 이루어진 후 다음 b 칼럼을 기준으로 2차 정렬을 하여
> 인덱스가 저장된다.

### 쿼리 시 index 사용 여부 확인
> 쿼리 앞에 `explain` 키워드를 붙여서 확인한다.  
> 예시) `explain select * from member where id = 5;`

### 주의 사항
> 이미 서비스 중인 테이블에 index 를 추가할 경우에는 주의하여 추가해야한다.  
> 많은 row 가 있는 테이블에 index 를 추가할 경우 인덱스 생성 시간이 길게는 몇 십분도 걸릴 수 있으며, 인덱스 생성 시에는 write 성능을 저하시키기
> 때문에 트래픽이 적은 시간을 골라서 index 를 생성하는 것을 권장한다.(Read 성능은 크게 저하되지 않는다.)

### B tree
> index 는 B tree 를 사용하여 관리된다.  
> B tree 사용 시 Binary tree 인 AVL tree, red-black tree 보다 장점은 다음과 같다.  
> 1.B tree 인덱스는 Binary tree 에 비해 Secondary storage(SSD or HDD) 에 접근을 적게 한다.  
> 2.B tree 노드는 block 단위의 저장 공간을 알차게 사용할 수 있다. Secondary storage 에서 Main memory(RAM) 으로 데이터를 로드할 때는 일정 block 단위로
> 데이터를 로드하기 때문에 찾는 데이터 이상의 데이터를 로드할 수 밖에 없다. Binary tree 의 경우 한 노드가 가지고 있는 정보가 적은 반면 B tree 는 Binary tree 에 비해
> 한 노드가 가지고 있는 정보가 많아 같은 block 단위의 데이터 로드 시 보다 의미 있는 데이터가 많이 포함되어 있다.
>
> hash index 사용 시에는 삽입/삭제/조회의 시간 복잡도가 O(1) 이지만 equality(=) 조회만 가능하고 범위 기반 검색이나 정렬에는 사용될 수 없다는 단점이 있다.

### Clustered index
> 데이터 페이지는 실제 데이터가 저장된 영역으로 clustered index 의 leaf node 는 데이터 페이지를 담고 있다.    
> 테이블 생성 시 하나의 칼럼에 Primary key 를 지정하면 해당 칼럼에 대한 clustered index 가 생성된다.  
> clustered index 는 테이블 당 한개씩만 존재한다. 그래서 테이블에서 index 를 걸면 가장 효율적일거 같은 칼럼을 
> clustered index 로 지정한다.
>  
> 예를 들어 id 칼럼을 PK 로 지정하면 clustered index 가 생성되면서 id 칼럼을 기준으로 정렬된 인덱스를 생성한다.  
> 해당 인덱스의 leaf node 에는 id 칼럼과 실제 데이터가 저장된 영역인 데이터 페이지가 저장되어 있다.    
> 그래서 해당 인덱스를 통해서 조회하게 되면 추가적인 조회가 필요없이 모든 칼럼의 데이터를 조회할 수 있다.  

### Non-clustered index
> 데이터 페이지는 그냥 둔 상태에서 별도의 페이지에 인덱스를 구성한다.  
> 인덱스 노드는 인덱스 칼럼과 데이터 페이지의 포인터로 구성된다.  
> 예를 들어 phone 칼럼에 index 를 걸었다고 가정하자. 그럼 Non-clustered index 가 생성되어 phone 칼럼을 기준으로
> 정렬된 인덱스를 생성한다. 해당 인덱스의 leaf node 에는 phone 칼럼과 데이터 페이지의 포인터가 저장되어 있다.
> 그래서 해당 인덱스를 통해서 조회하게 되면 phone 칼럼을 기준으로 검색하여 데이터 페이지의 포인터를 찾은 후에 
> 데이터 페이지의 포인터를 통해 데이터 페이지를 조회하는 추가 작업이 존재한다.  
> 그래서 Non-clustered index 에 비해 clustered index 가 성능적으로 더 좋다.   

### 참조사이트
> [[SQL] Clustered Index & Non-Clustered Index](https://velog.io/@gillog/SQL-Clustered-Index-Non-Clustered-Index)
> [[SQL] 인덱스 (클러스터, 비클러스터) 개념](https://mongyang.tistory.com/75)

---

## Sharding
### Horizontal partitioning
> 테이블에 row 가 많이 쌓이게 되면 그만큼 인덱스 정보 역시 많이 쌓이게 된다.
> 인덱스가 많이 쌓이게되면 데이터 삽입/삭제 시 B tree 의 노드 정렬 과정에 걸리는 시간이 길어질 수 있다.
> 그래서 Horizontal partitioning 을 통해서 row 를 동일한 스키마의 테이블의 갯수를 늘려서 나눠서 저장하는 것이 Horizontal partitioning 이다.  
> 하나의 DB 서버에 테이블의 갯수를 늘려서 저장하면 Horizontal partitioning 이고, 늘린 테이블을 서로 다른 각각의 DB 서버를 만들어서 나누면 Sharding 이다.  
> Sharding 하여 각 DB 서버로 테이블을 나누게 되면 하나의 DB 서버를 사용할 때 발생한 트래픽이 여러 DB 서버로 분산된다.

### Partition key
> Hash 알고리즘을 통해서 각 테이블로 파티셔닝이 되는데 Hash 알고리즘에 사용할 key 를 partition key 라고 한다.  
> partition key 를 통해서 조회하게 되면 해당 partition key 를 가지고 있는 DB 서버에서만 데이터를 탐색하면 된다.  
> 하지만 partition key 가 아닌 칼럼으로 조회 시 모든 DB 서버에서 데이터를 탐색해야 한다.  
> 그러므로 사용하는 애플리케이션에서 특정 key 를 통해서만 조회를 해도 문제 없도록 데이터 엑세스 패턴을 고민하여 partition key 설계를 할 필요가 있다.

---

## Data migration
### 기본
> TODO

### 무중단 migration
> TODO

---

## DBCP(DB Connection Pool)
### DB 와 Application 과 연결
> Application 과 DB 서버는 일반적으로 분리된 서버로 구성되며 둘의 연결은 TCP 기반으로 동작한다.
> TCP 는 연결 지향성을 가지며 높은 송수신 신뢰성을 가지지만 데이터 송수신 이전에 connection 을 open 하는 과정과 송수신이 모두 완료되어 더이상
> connection 이 필요없어진 경우 close 하는 과정이 필요하다. open 및 close 동작 과정은 시간이 소요되는 작업이다.  
> 그렇기 때문에 단순히 쿼리 1번을 DB 에 송신하기 위해서 TCP connection 을 open 하고 close 하는 것은 시간적인 비용이 발생하여 서비스 성능에 좋지 않다.

### DBCP
> Application 은 DBCP 를 이용하여 DB 와의 (TCP) connection 을 여러개 (설정한 만큼) open 하여 connection 정보들을 pool 에 저장한다.
> Application 에 DB 를 조회하는 요청이 오면 pool 에서 connection 정보를 하나 가져와서 DB 에 조회 쿼리를 송수신하여 통신 후에 통신이 끝나면
> pool 에 connection 을 반납한다. 반납된 connection 은 종료되지 않고 다른 요청이 오면 해당 요청에 connection 정보를 주고 요청이 끝나면 
> connection 정보를 받기를 반복한다.

### DB 서버 설정
> `max_connections`: client 와 맺을 수 있는 최대 connection 수   
> 
> `wait_timeout`  
> connection 이 inactive 할 때 (사용되지 않을 때) 다시 요청이 오기까지 얼마의 시간을 기다린 뒤에 close 할 것인지를 결정. 기본값은 28800 으로 8시간이다.  
> 비정상적인 connection 종료, connection 이 다 쓰고 반환이 안된 경우, 네트워크가 단절된 경우 application 이 가지고 있던 connection 을 
> DB 서버에 close 를 하지 못한 상태가 될 수 있다.
> 이렇게 되면 DB 서버의 connection 들은 close 가 안되어 있어 누군가와 연결이 되어 있는 상태이지만 실제로는 사용이 될 수 없는 상태가 되어 
> DB 서버의 connection 만 잡아먹고 있는 상태가 되어 버리기 때문에 `wait_timeout` 에 시간을 설정하여 일정 시간 동안 connection 을 통해
> 쿼리 송수신이 이루어지지 않으면 DB 서버에서 커넥션을 종료를 하는 것이 바람직하다.

### HikariCP
> `minimumIdle`  
> pool 에서 유지하는 최소한의 idle connection 수.  
> 기본 값은 maximumPoolSize 로 설정된 값이다.    
> 
> `maximumPoolSize`  
> pool 이 가질 수 있는 최대 connection 수. 
> inactive(idle) 과 active(in-use) connection 을 모두 합친 최대 수.  
> 기본 값은 10개이다.
> 
> pool 에 처음 존재하는 connection 의 갯수는 `minimumIdle`에서 설정한 갯수이다.  
> 요청으로 인하여 pool 에 있는 connection 이 active(in-use) 상태로 변하여 idle connection 의 갯수가 1개 줄게 되면 `minimumIdle` 의 갯수에 맞춰
> connection 을 하나 더 추가한다. 이렇게 계속 요청으로 connection 이 active 상태로 변하여 connection 을 계속 추가하다가 active connection 과
> inactive connection 의 총합이 `maximumPoolSize` 의 값과 같아지면 더이상 connection 을 생성하지 않는다.
>
> `minimumIdle` 의 기본 값은 maximumPoolSize 와 동일하며 HikariCP 에서 권장하고 있다.
> 이렇게 되면 connection 이 처음부터 maximumPoolSize 만큼 만들어져 있음으로 connection 이 active 상태가 된다고 해서 connection 을 더 만들지 않고
> 처음부터 고정된 pool size 를 갖게 된다.  
> 이렇게 권장하는 이유는 DB connection 연결은 시간을 소요하는 작업이며 그로 인하여 해당 Application 의 성능이 일정 기간 낮아질 수 있다.  
> 
> `maxLifetime`  
> pool 에서 connection 의 최대 수명. 기본 값은 30분이다.   
> maxLifetime 을 넘기면 idle 일 경우 pool 에서 바로 제거, active 인 경우 pool 로 반환된 후 제거한다. 하지만 모종의 이유로 active 인 connection 이
> pool 로 반환되지 않은 상태가 지속되는 경우 해당 connection 은 maxLifetime 을 넘어서도 제거가 되지 않는다.  
> maxLifetime 은 connection time limit(wait_timeout) 보다 몇 초 짧게 설정해야 한다. maxLifetime 과 wait_timeout 이 동일하다면 
> 어떤 connection 이 maxLifetime 에 거의 다 되어 1초 이하로 남았다고 가정해보자. 그런데 해당 connection 이 요청되어 쿼리가 DB 로 전송되는 중에
> wait_timeout 이 되어버리면 도중에 에러가 날 수 있음으로 wait_timeout 이 발생하지 않도록 maxLifetime 을 wait_timeout 보다 몇 초 정도 적게 설정하자.  
>
> `connectionTimeout`  
> pool 에서 connection 을 받기 위해 최대로 대기하는 시간. 디폴트는 30000 으로 30초이다.    
> 트래픽이 몰려 pool 에 있는 connection 이 모두 사용되고 있을 때 추가로 요청이 발생하면 해당 요청은 pool 에서 connection 을 받기 위해 대기하게 된다.
> 이때 connectionTimeout 에 설정한 시간까지 요청이 대기하게 되고 대기 시간이 설정한 시간을 넘어가면 Exception 이 발생하게 된다.    
> connectionTimeout 은 결국 트래픽이 몰렸을 때 애플리케이션을 사용하는 유저가 최대 얼마의 시간까지 기다리게할 것인가를 설정하는 값이다.  
> 일반적으로 사용자는 10초 이상을 응답 대기에 사용하지 않을 가능성이 크기 때문에 적절한 값을 설정하는 것이 중요하다. (0.5초에서 3초 사이 정도로 하는 것이 권장된다.)

### TODO
> [JDBC 커넥션 풀들의 리소스 관리 방식 이해하기](https://kakaocommerce.tistory.com/45)  
> [Commons DBCP 이해하기](https://d2.naver.com/helloworld/5102792)  
> [JDBC Internal - 타임아웃의 이해](https://d2.naver.com/helloworld/1321)  

---

## PK 생성 전략
### Sequential Number
> Java + JPA 를 기준으로 long 타입을 사용하며 long 타입은 8 byte 이다.  
> 8 byte 는 64 bit 이며 최댓값은 9,223,372,036,854,775,807(922경)이다.  
> 이 선택지의 주요 컨셉은 auto incremental ID를 선택했을 때 외부에 노출되는 것이 문제라면, 외부에 노출될 때 hashing 을 통해서 노출하자라는 것이다.   
> 예를 들면 ID가 12345 일 때 hashing 을 통해서 ‘3sy561e’ 와 같이 변환해서 노출할 수 있다. 
> 해싱에서는 salt 로 사용되는 값을 정할 수 있는데 이 값을 관리하여 ‘3sy561e’ 라는 값을 다시 12345 와 같이 변환할 수 있다. 
> 따라서 이 값은 외부에 노출되면 안된다.  

### UUID 
> Universally Unique Identifier  
> 중복되는 UUID 를 생성활 확률은 극히 희박하다. 거의 0% 에 수렴한다고 보면 된다.  
> UUID 중 Version 4 의 경우 랜덤으로 생성한다. 이렇게 랜덤으로 생성되는 UUIDv4 를 B-Tree 를 사용하는 MySQL 에 PK 로 사용하는 경우 
> INSERT, DELETE 시 B-Tree 재배열이 발생하여 오버헤드가 발생한다. 이로인해 대량의 데이터 발생 시 Sequential Number 에 비해서 성능이 낮다.      
> 또한 길이도 32 byte 의 문자열이며 바이너리로 저장시 16 byte 길이로 저장된다.  

### TSID
> Time-Sorted Unique Identifier 를 생성하는 Java Library 이다.  
> [GitHub - tsid-creator](https://github.com/f4b6a3/tsid-creator) 에서 자세한 내용을 확인할 수 있다.  
> 숫자로 저장 시 64 bit long 타입으로 저장할 수 있다.  
> 문자열로 저장 시 13 글자 길이의 문자열로 저장할 수 있다.   
> 문자열 포맷은 Base 64 포멧이다.  
> 1 밀리세컨드 마다 만들 수 있는 TSID 의 최대 갯수는 4,096개이다. 1 초에는 4,096,000 개이다.  

### ULID
> Universally Unique Lexicographically Sortable Identifier  
> 문자열로 저장 시 26 글자 길이의 문자열로 저장할 수 있다.  
> 바이트로 저장 시 16 byte 길의이 배열로 저장할 수 있다.  
> UUID 및 GUID 로 저장할 수 있다.
> 
> ULID는 생성 순서를 밀리세컨 단위로 기록할 수 있어서, 생성 순서대로 정렬을 할 때 편하다.  
> 만약 같은 밀리세컨드 단위까지 일치하는 시간에 만들어졌고, 여러 컴퓨터에서 사용한다면 순서는 랜덤이 된다.  
> 애초에 ULID는 UUID의 단점을 극복하고자 만들어졌다. (UUID는 타임스탬프 같은 배경 없이 그냥 무작위의 값을 생성해낸다.)  
> Crockford’s Base32 에 기반해서 만들어졌기 때문에 (I, L, O, U)는 제외된다. (제외되는 이유는 사람 눈에 헷갈리기 때문이다). 
> 또한 ULID는 UUID를 생성하는 것보다 나은 성능을 보이기도 한다.  
> 
> 충돌 가능성: 위의 논리대로라면 1ms에 2^80개까지 만들수 있다는 것이다.

### 참조사이트
> [[시스템 디자인] ID Generator 알아보기 (feat: Twitter Snowflake, tsid)](https://tech-monster.tistory.com/228)
> [UUID vs ULID](https://velog.io/@injoon2019/UUID-vs-ULID)
