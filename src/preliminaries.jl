# Copyright (c) 2025 Quan-feng WU <wuquanfeng@ihep.ac.cn>
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

path_to_bin = joinpath((dirname ∘ dirname ∘ pathof)(@__MODULE__), "externals", "bin")

function set_PATH()
    startswith(ENV["PATH"], path_to_bin) || (ENV["PATH"] = path_to_bin * ":" * ENV["PATH"])
    return ENV["PATH"]
end

function set_FIRE()
    ENV["FIRE_BIN"] = joinpath(path_to_bin, "FIRE7")
end
