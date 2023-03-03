# rdb-starter

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
> 그래서 read-lock 과 write-lock 을 동시성으로 처리하기 위해서 도입된 것이 MVCC 임.  

### 특징
> 1.MVCC 는 isolation level 을 기준으로 가장 최근에 commit 된 데이터를 읽는다.  
> 2.마지막 데이터만 읽는 것이 아닌 특정 시점의 데이터를 읽을 수 있기 때문에 MVCC 는 데이터 변화(write한 데이터) 이력을 관리한다.  
> 3.read 와 write 는 서로를 block 하지 않는다.  

### Locking read
> PostgreSQL 의 경우 isolation level 이 REPEATABLE READ 면 추가 설정 없이 Lost Update 를 방지하면서 동시성 처리를 제공한다.  
> 하지만 MySQL 의 경우 isolation level 이 REPEATABLE READ 만으로는 Lost Update 를 방지하지 못하여 REPEATABLE READ 과 
> Locking read 를 통해서 Lost Update 방지 및 동시성 처리를 제공해야한다.   
> 
> 특징  
> locking read 는 MySQL 에서는 write lock 이 걸린 데이터에 접근하려하면 대기 후 
> lock 풀려서 조회할 때 가장 최근에 commit 된 데이터를 읽는다.
> 
> locking read 는 PostgreSQL 에서는 먼저 write lock 이 걸린 데이터에 접근하려하면 대기 후 
> lock 풀려서 조회할 때 먼저 update 한 tx 가 있어서 해당 tx 가 commit 되면 나중 tx 는 rollback 된다.
> 
> 종류
> write-lock: `select ... for update`  
> 조회 시 뒤에 `for update` 를 기재하여 write-lock 을 건다.  
> 
> read-lock: `select ... for share`  
> 조회 시 뒤에 `for share` 를 기재하여 read-lock 을 건다.

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

## set 과 multiset
### set
> 중복을 허용하지 않는 유일한 원소만 가질 수 있는 자료구조이다.

### multiset
> 중복을 허용하는 set 이다.

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

## DDL(Data Definition Language)
### 실시간 테이블 스키마 변경
> MySQL 8.0 이후 버전에서는 테이블 스키마를 다운 타임 없이 실시간으로 변경할 수 있는 기능을 제공  
> `ALTER TABLE table_name [alter_specification], ALGORITHM=INSTANT;`  
> 기존 alter table 쿼리 뒤에 `, ALGORITHM=INSTANT` 를 붙이면 실시간으로 스키마 변경이 가능해짐.   
> 참조사이트: [MySQL 8.0: InnoDB now supports Instant ADD COLUMN](https://dev.mysql.com/blog-archive/mysql-8-0-innodb-now-supports-instant-add-column/)  

---

## DML(Data Manipulation Language)
### like
> `%`: 0~N 개의 문자 검색  
> ex) nickname like '%동%' => 결과 값으로 땡땡땡동땡 과 같이 앞뒤로 붙는 글자가 0개 ~ N개가 될 수 있음.
> 
> `_`: 1개의 문자 검색  
> ex) nickname like '_동_' => 결과 값으로 문동은 과 같이 1글자만 대응됨.  

### exists
> 서브쿼리가 반화나는 결과값이 있는지를 조사한다.
> 단지 반환된 행이 있는지 없는지만 보고 값이 있으면 참 없으면 거짓을 반환한다.
>
> 한 테이블이 다른 테이블과 외래키(FK)와 같은 관계가 있을 때 유용  
> 조건에 해당하는 ROW의 존재 유무와 이후 더 수행하지 않음 (지연 평가 원리 이기 때문에 성능이 좋다)  
> 일반적으로 SELECT절까지 가지 않기에 IN에 비해 속도나 성능면에서 더 좋음  
> 반대로 조건에 맞지 않는 ROW만 추출하고 싶으면 NOT EXISTS  
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
> 예를 들어 employee 테이블과 department 테이블이 inner join 을 할 때 employee tuple 에 foreign key 인 dept_id 가 null 인 경우 해당 tuple 은 결과 값에 나오지 않는다.  

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
