using CSV
using DataFrames
using Dates
using SplitApplyCombine
using Plots

orders = CSV.read("orders.csv", DataFrame)

orders_per_day = groupcount(Date.(orders.datetime))

df = DataFrame(
    Date = collect(keys(orders_per_day)),
    Orders = collect(values(orders_per_day))
)

chart = bar(
    df.Date,
    df.Orders;
    title = "Orders per day",
    xaxis = "Date",
    yaxis = "Number of orders",
    legend = false
)

CSV.write("orders_per_day.csv", df)