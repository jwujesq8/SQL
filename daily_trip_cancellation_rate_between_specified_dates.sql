select 
    trips.request_at as Day,
    round(
        sum(case 
                when trips.status in ('cancelled_by_driver','cancelled_by_client')
                    then 1 
                else 0 
            end
        ) / count(*), 
        2
    ) as 'Cancellation Rate'
from Trips trips
    join Users clients 
        on trips.client_id = clients.users_id and clients.banned = 'No'
    join Users drivers
        on trips.driver_id = drivers.users_id and drivers.banned = 'No'
where trips.request_at between '2013-10-01' and '2013-10-03'
group by trips.request_at
