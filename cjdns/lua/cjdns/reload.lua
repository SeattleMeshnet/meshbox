common = require("cjdns/common")

function common.reload(admin, config)
    local response = { added = {}, removed = {} }

    local expected = config.authorizedPasswords

    local res, err = admin:auth({ q = "AuthorizedPasswords_list" })
    if err then return response, err end
    local actual = res.users

    -- for i, v in ipairs(expected) do
    --     for j, p in pairs(v) do print("expected", i, j, p) end
    -- end
    -- for i, v in ipairs(actual) do print("actual", i, v) end

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
            local res, err = admin:auth({
                q = "AuthorizedPasswords_add",
                password = password.password,
                user = password.user
            })
            if err then return response, err end
            table.insert(response.added, user)
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
            local res, err = admin:auth({
                q = "AuthorizedPasswords_remove",
                user = user
            })
            if err then return response, err end
            -- TODO: InterfaceController_disconnectPeer(publicKey)
            table.insert(response.removed, user)
        end
    end

    return response, nil
end
