with distinct_salaries_cte as (
    select distinct e.salary
    from Employee e
)
select 
    case
        when (
            select count(*)
            from distinct_salaries_cte
            ) < 2 then null
        else (
            select * 
            from distinct_salaries_cte
            order by salary desc
            limit 1 OFFSET 1
            )
    end as SecondHighestSalary;