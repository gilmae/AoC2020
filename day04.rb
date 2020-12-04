require './helper.rb'
include Helper

data = get_data("#{__FILE__}".gsub(/\.rb/, ".input")).join("")

lines = data.split("\n\n")

def valid_passport_simple?(passport)
    passport.keys.length == 8 || (passport.keys.length == 7 && passport["cid"].nil?)
end

def valid_passport_secure?(passport)
    birthYear = passport["byr"]
    return false unless !birthYear.nil? && birthYear.to_i >= 1920 && birthYear.to_i <= 2002

    iyr = passport["iyr"]
    return false unless !iyr.nil? && iyr.to_i >= 2010 && iyr.to_i <= 2020

    eyr = passport["eyr"]
    return false unless !eyr.nil? && eyr.to_i >= 2020 && eyr.to_i <= 2030

    hcl = passport["hcl"]
    return false unless !hcl.nil? && hcl.match(/^#[0-9a-fA-F]{6}$/)

    ecl = passport["ecl"]
    return false unless !ecl.nil? && ecl.match(/(amb|blu|brn|gry|grn|hzl|oth){1}/)
    
    pid = passport["pid"]
    return false unless !pid.nil?  && pid.match(/^\d{9}$/)

    hgt = passport["hgt"]
    return false if hgt.nil?
    type = hgt.chars.last(2).join
    return (type == "cm" && hgt.to_i >=150 && hgt.to_i <=193) || (type=="in" && hgt.to_i >= 59 && hgt.to_i <= 76)
end


passports = lines.map {|passport|
    passport.gsub(/\n/, " ").split(" ").map{ |l|  l.split(":")}.to_h
}

puts passports.reduce(0){ | memo, item |
    if valid_passport_simple? item
        memo + 1
    else
        memo + 0
    end
}

puts passports.reduce(0){ | memo, item |
    if valid_passport_secure? item
        memo + 1
    else
        memo + 0
    end
}
