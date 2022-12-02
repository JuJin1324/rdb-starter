# rdb-starter

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
> InnoDB에서 기본적으로 순수한 SELECT 작업은 아무런 잠금을 걸지않고 동작하는데,  
> 격리수준이 SERIALIZABLE일 경우 읽기 작업에도 공유 잠금을 설정하게 되고, 이러면 동시에 다른 트랜잭션에서 이 레코드를 변경하지 못하게 된다.  
> 이러한 특성 때문에 동시처리 능력이 다른 격리수준보다 떨어지고, 성능저하가 발생하게 된다.  

### 참조사이트
> [[db] 트랜잭션 격리 수준(isolation level)](https://joont92.github.io/db/%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B2%A9%EB%A6%AC-%EC%88%98%EC%A4%80-isolation-level/)
