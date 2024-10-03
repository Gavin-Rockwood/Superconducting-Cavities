function load_python(file)
    #saved_dict = JSON.parsefile(file)
    saved_dict = JSON3.read(file, Dict{Any, Any})
    Eᶜ = saved_dict["Main_Config"]["E_C"]
    Eʲ = saved_dict["Main_Config"]["E_J"]
    Eᵒˢᶜs = saved_dict["Main_Config"]["E_osc"]
    gs = saved_dict["Main_Config"]["g"]
    ng = saved_dict["Main_Config"]["transmon_ng"]
    
    Nₜ = saved_dict["Main_Config"]["transmon_truncated_dim"]
    Nᵣs = saved_dict["Main_Config"]["resonator_truncated_dim"]
    Nₜ_cut = saved_dict["Main_Config"]["transmon_ncut"]

    Model_Name = saved_dict["Main_Config"]["model_name"]
    Save_Path = saved_dict["Main_Config"]["save_path"]
    

    Cavity_Names = saved_dict["Cavity_Names"]

    κᵗᶜ = saved_dict["Extra_Stuff"]["CandD_Coefs"]["T_C"]
    κᵗᵈ = saved_dict["Extra_Stuff"]["CandD_Coefs"]["T_D"]
    κᶜᶜ = saved_dict["Extra_Stuff"]["CandD_Coefs"]["C_C"]

    model = init(Eᶜ, Eʲ, Eᵒˢᶜs, gs, Nₜ, Nᵣs, Nₜ_cut=Nₜ_cut, ng=ng, Cavity_Names=Cavity_Names, κᵗᶜ=κᵗᶜ, κᵗᵈ=κᵗᵈ, κᶜᶜ = κᶜᶜ, Model_Name = Model_Name, Save_Path =Save_Path)

    if "op_drive_params_dict" in keys(saved_dict)
        model.Stuff["op_drive_params"] = saved_dict["op_drive_params_dict"] 
    else
        model.Stuff["op_drive_params"] = Dict{Any, Any}()
    end
    if "Drive_Sequences" in keys(saved_dict)
        model.Stuff["Drive_Sequences"] = saved_dict["Drive_Sequences"]
    else
        model.Stuff["Drive_Sequences"] = Dict{Any, Any}()
    end

    return model
end


function save_model(model::TransmonResonators; model_name = nothing, save_path = nothing)
    save_dict = Dict{Any, Any}()
    save_dict["Main_Config"] = model.params
    save_dict["Stuff"] = Dict{Any, Any}()
    
    if "op_drive_params" in keys(model.Stuff)
        save_dict["Stuff"]["op_drive_params"] = model.Stuff["op_drive_params"]
    end
    if "Drive_Sequences" in keys(model.Stuff)
        save_dict["Stuff"]["Drive_Sequences"] = model.Stuff["Drive_Sequences"]
    end

    if ("ModelType" in keys(save_dict["Main_Config"]))
        save_dict["Main_Config"]["ModelType"] = "TransmonResonators"
    end

    save_path = model.params["Save_Path"]
    filename = save_path*model.params["Model_Name"]

    
    if !isdir(save_path)
        @info "Making Save Directory $save_path"
        mkdir(save_path)
    end

    #### Making Backup
    try 
        cp(filename*".json", filename*"_BACKUP"*".json")
        rm(filename*".json")
    catch
    end

    open(filename*".json", "w") do f
        JSON3.pretty(f, save_dict)
    end
    try 
        rm(filename*"_BACKUP"*".json")
    catch
    end


end

function load(file)
    #saved_dict = JSON.parsefile(file)
    if typeof(file) <: String
        saved_dict = JSON3.read(file, Dict{Any, Any})
    else
        save_dict = file
    end

    
    Eᶜ = saved_dict["Main_Config"]["E_C"]
    Eʲ = saved_dict["Main_Config"]["E_J"]
    Eᵒˢᶜs = saved_dict["Main_Config"]["E_oscs"]
    gs = saved_dict["Main_Config"]["gs"]
    ng = saved_dict["Main_Config"]["ng"]
    
    Nₜ = saved_dict["Main_Config"]["Nt"]
    Nᵣs = saved_dict["Main_Config"]["Nrs"]
    Nₜ_cut = saved_dict["Main_Config"]["Nt_cut"]

    κᵗᶜ = saved_dict["Main_Config"]["kappa_tc"]
    κᵗᵈ = saved_dict["Main_Config"]["kappa_td"]
    κᶜᶜ = saved_dict["Main_Config"]["kappa_cc"]

    Model_Name = saved_dict["Main_Config"]["Model_Name"]
    Save_Path = saved_dict["Main_Config"]["Save_Path"]

    Cavity_Names = saved_dict["Main_Config"]["Cavity_Names"]

    

    model = init(Eᶜ, Eʲ, Eᵒˢᶜs, gs, Nₜ, Nᵣs, Nₜ_cut=Nₜ_cut, ng=ng, Cavity_Names=Cavity_Names, κᵗᶜ=κᵗᶜ, κᵗᵈ=κᵗᵈ, κᶜᶜ = κᶜᶜ, Model_Name = Model_Name, Save_Path = Save_Path)
    
    if "op_drive_params" in keys(saved_dict["Stuff"])
        model.Stuff["op_drive_params"] = saved_dict["Stuff"]["op_drive_params"]
    else 
        model.Stuff["op_drive_params"] = Dict{Any, Any}()

    end
    if "Drive_Sequences" in keys(saved_dict["Stuff"])
        model.Stuff["Drive_Sequences"] = saved_dict["Stuff"]["Drive_Sequences"]
    else
        model.Stuff["Drive_Sequences"] = Dict{Any, Any}()
    end

    return model
end