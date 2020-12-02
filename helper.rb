module Helper
    def get_data(name)
        return File.readlines("inputs/#{name}")
    end
end