-- =====================================================
-- Time to Conversion Analysis
-- =====================================================

WITH user_journey AS (

    SELECT

        user_id,

        MIN(
            CASE 
                WHEN event_type = 'page_view' 
                THEN event_date::timestamp 
            END
        ) AS view_time,

        MIN(
            CASE 
                WHEN event_type = 'add_to_cart' 
                THEN event_date::timestamp 
            END
        ) AS cart_time,

        MIN(
            CASE 
                WHEN event_type = 'purchase' 
                THEN event_date::timestamp 
            END
        ) AS purchase_time

    FROM ecommerce_events

    WHERE event_date::date >= '2025-12-01'

    GROUP BY user_id

    HAVING MIN(
        CASE 
            WHEN event_type = 'purchase' 
            THEN event_date::timestamp 
        END
    ) IS NOT NULL

)

SELECT

    COUNT(*) AS converted_users,

    ROUND(
        AVG(EXTRACT(EPOCH FROM (cart_time - view_time)) / 60),
        2
    ) AS avg_view_to_cart_minutes,

    ROUND(
        AVG(EXTRACT(EPOCH FROM (purchase_time - cart_time)) / 60),
        2
    ) AS avg_cart_to_purchase_minutes,

    ROUND(
        AVG(EXTRACT(EPOCH FROM (purchase_time - view_time)) / 60),
        2
    ) AS avg_total_journey_minutes

FROM user_journey;