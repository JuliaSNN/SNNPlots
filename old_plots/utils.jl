
rectangle(w, h, x, y) = Shape(x .+ [0, w, w, 0], y .+ [0, 0, h, h])

function hash_name(sample, text)
    _name = hash(sample.params |> struct2dict |> tostringdict |> string)
    _name = string(_name, "_", sample.params.name)
    _name = _name * "_$text"
    return _name
end
