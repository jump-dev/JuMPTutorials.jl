
using DataFrames
using XLSX


data_dir = joinpath(@__DIR__, "data")
excel_df = DataFrame(XLSX.readtable(joinpath(data_dir, "SalesData.xlsx"), "SalesOrders")...)


using CSV
csv_df = CSV.read(joinpath(data_dir, "StarWars.csv"), DataFrame)


ss_df = CSV.read(joinpath(data_dir, "Cereal.txt"), DataFrame)


delim_df = CSV.read(joinpath(data_dir, "Soccer.txt"), DataFrame, delim = "::")


size(ss_df)


nrow(ss_df), ncol(ss_df)


describe(ss_df)


names(ss_df)


eltype.(ss_df)


csv_df[1,1]


csv_df[!, 1]


csv_df[!, :Name]


csv_df.Name


csv_df[:, 1] # note that this creates a copy


csv_df[1:1, :]


csv_df[1, :] # this produces a DataFrameRow


excel_df[1:3, 5] .= 1


excel_df[4:6, 5] = [4, 5, 6]


excel_df[1:2, 6:7] =  DataFrame([-2 -2; -2 -2], [Symbol("Unit Cost"), :Total])


excel_df


passportdata = CSV.read(joinpath(data_dir, "passport-index-matrix.csv"), DataFrame, copycols = true)

for i in 1:nrow(passportdata)
    for j in 2:ncol(passportdata)
        if passportdata[i,j] == -1 || passportdata[i,j] == 3
            passportdata[i,j] = 1
        else
            passportdata[i,j] = 0
        end
    end
end


using JuMP, GLPK

# Finding number of countries
n = ncol(passportdata) - 1 # Subtract 1 for column representing country of passport

model = Model(GLPK.Optimizer)
@variable(model, pass[1:n], Bin)
@constraint(model, [j = 2:n], sum(passportdata[i,j] * pass[i] for i in 1:n) >= 1)
@objective(model, Min, sum(pass))
optimize!(model)

println("Minimum number of passports needed: ", objective_value(model))


countryindex = findall(value.(pass) .== 1 )

print("Countries: ")
for i in countryindex
    print(names(passportdata)[i+1], " ")
end

