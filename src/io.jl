using DataFrames, CSV

function result_to_csv(Sz_each_site::Vector{Float64}, c_xxs::Vector{Float64}, c_zzs::Vector{Float64}, filename::String)
    # Create a DataFrame to hold the results
    df = DataFrame(
        Sz_each_site = Sz_each_site,
        c_xxs        = c_xxs,
        c_zzs        = c_zzs
    )
    # Write the DataFrame to a CSV file
    CSV.write(filename, df)
end