# rdb-starter

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
> Phantom READ  
> 트랜잭션 A 가 시작되고 트랜잭션 B 에서 row 를 1개 Insert 하고 커밋한다. 그 후 트랜잭션 A 에서 트랜잭션 B 에서 Insert 한 row 를 조회하려해도 
> 조회되지 않는다(여기까지는 정상). 하지만 트랜잭션 A 에서 조회되지 않았던 row 의 ID 로 Update 문을 실행하면 Update 가 정상적으로 진행되며,
> 이후부터 해당 row 의 ID 로 조회를 시도하려 하면 조회가 되버린다.  
> mySQL 의 InnoDB 엔진에서는 REPEATABLE READ 에서도 Phantom READ 가 발생하지 않는다.   

### SERIALIZABLE
> InnoDB 에서 기본적으로 순수한 SELECT 작업은 아무런 잠금을 걸지않고 동작하는데,  
> 격리수준이 SERIALIZABLE일 경우 읽기 작업에도 공유 잠금을 설정하게 되고, 이러면 동시에 다른 트랜잭션에서 이 레코드를 변경하지 못하게 된다.  
> 이러한 특성 때문에 동시처리 능력이 다른 격리수준보다 떨어지고, 성능저하가 발생하게 된다.  

### 참조사이트
> [[db] 트랜잭션 격리 수준(isolation level)](https://joont92.github.io/db/%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B2%A9%EB%A6%AC-%EC%88%98%EC%A4%80-isolation-level/)


