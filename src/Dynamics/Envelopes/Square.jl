function Square_Envelope(t)
    return 1.0
end
Envelope_Dict["Square"] = Square_Envelope



function Square_Envelope_Cal(x...)
    t = x[1]
    Envelope_Args = x[2]
    return Envelope_Args
end
Envelope_Dict_Cal["Square"] = Square_Envelope_Cal






