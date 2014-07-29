common = require("cjdns/common")

function common.reload(admin, config)
    local expected = config.authorizedPasswords

    local response, err = admin:auth({ q = "AuthorizedPasswords_list" })
    if err then return nil, err end
    local actual = response.users

    for i, v in ipairs(expected) do
        for j, p in pairs(v) do print("expected", i, j, p) end
    end
    for i, v in ipairs(actual) do print("actual", i, v) end

    -- make sure expected passwords are present
    for _, password in ipairs(expected) do
        local found = nil
        for _, user in ipairs(actual) do
            if user == password.user then
                found = 1
                break
            end
        end

        if not found then
            print("Adding " .. user)
            local response, err = admin:auth({
                q = "AuthorizedPasswords_add",
                password = password.password,
                user = password.user
            })
            if err then return nil, err end
            print("error", response.error)
        end
    end

    -- make sure outdated passwords are not present
    for _, user in ipairs(actual) do
        local found = nil
        if user == "Local Peers" then
            found = 1
        else
            for _, password in ipairs(expected) do
                if user == password.user then
                    found = 1
                    break
                end
            end
        end

        if not found then
            print("Removing " .. user)
            local response, err = admin:auth({
                q = "AuthorizedPasswords_remove",
                user = user
            })
            if err then return nil, err end
            print("error", response.error)
            -- InterfaceController_disconnectPeer(publicKey)
        end
    end

    return nil, nil
end
