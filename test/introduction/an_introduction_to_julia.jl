
println("Hello, World!")


typeof(1 + -2)


typeof(1.2 - 2.3)


π


typeof(π)


typeof(2 + 3im)


typeof("This is Julia")


typeof("π is about 3.1415")


:my_id
typeof(:my_id)


1 + 1


(2 + 1im) * (1 - 2im)


sin(2π/3) == √3/2


sin(2π/3) - √3/2


sin(2π/3) ≈ √3/2


1 + 1e-16 == 1


(1 + 1e-16) - 1e-16 == 1 + (1e-16 - 1e-16)


b = [5, 6]


A = [1 2; 3 4]


x = A \ b


A * x


A * x == b


@show b' * b
@show b * b';


t = ("hello", 1.2, :foo)


typeof(t)


t[2]


a, b, c = t
b


t = (word="hello", num=1.2, sym=:foo)


t.word


d1 = Dict(1 => "A", 2 => "B", 4 => "D")


d1[2]


Dict("A" => 1, "B" => 2.5, "D" => 2 - 3im)


d2 = Dict("A" => 1, "B" => 2, "D" => Dict(:foo => 3, :bar => 4))


d2["B"]


d2["D"][:foo]


for i in 1:5
    println(i)
end


for i in [1.2, 2.3, 3.4, 4.5, 5.6]
    println(i)
end


for (key, value) in Dict("A" => 1, "B" => 2.5, "D" => 2 - 3im)
    println("$key: $value")
end


i = 10
for i in 0:3:15
    if i < 5 
        println("$(i) is less than 5")
    elseif i < 10
        println("$(i) is less than 10")
    else
        if i == 10
            println("the value is 10")
        else
            println("$(i) is bigger than 10")
        end
    end
end


[i for i in 1:5]


[i*j for i in 1:5, j in 5:10]


[i for i in 1:10 if i%2 == 1]


Dict("$i" => i for i in 1:10 if i%2 == 1)


function print_hello()
    println("hello")
end
print_hello()


function print_it(x)
    println(x)
end
print_it("hello")
print_it(1.234)
print_it(:my_id)


function print_it(x; prefix="value:")
    println("$(prefix) $x")
end
print_it(1.234)
print_it(1.234, prefix="val:")


function mult(x; y=2.0)
    return x * y
end
mult(4.0)


mult(4.0, y=5.0)


[1, 5, -2, 7]


[1.0, 5.2, -2.1, 7]


function mutability_example(mutable_type::Vector{Int}, immutable_type::Int)
    mutable_type[1] += 1
    immutable_type += 1
    return
end

mutable_type = [1, 2, 3]
immutable_type = 1

mutability_example(mutable_type, immutable_type)

println("mutable_type: $(mutable_type)")
println("immutable_type: $(immutable_type)")


@show isimmutable([1, 2, 3])
@show isimmutable(1);


using Random
Random.seed!(33);

[rand() for i in 1:10]

