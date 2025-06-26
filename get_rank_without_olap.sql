select 
    s1.score,
    count(distinct s2.score) as `rank`
from Scores s1
join Scores s2 on s2.score >= s1.score
group by s1.id
order by s1.score desc