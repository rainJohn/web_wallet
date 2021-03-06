servicesModule = angular.module("app.services")

servicesModule.factory "Utils", ->
    asset: (amount, asset_type) ->
        amount: amount
        symbol: asset_type.symbol
        precision: asset_type.precision

    newAsset: (amount, symbol, precision) ->
        amount: amount
        symbol: symbol
        precision: precision

    formatAsset: (asset) ->
        if not asset
            return ""
        parts = (asset.amount / asset.precision).toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.join(".") + " " + asset.symbol

    formatAssetPrice: (asset) ->
        if not asset
            return ""
        parts = (asset.amount / asset.precision).toString().split(".")
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        parts.join(".")
    
    toDate: (t) ->
        new Date(@toUTCDate(t))

    toUTCDate: (t) ->
        dateRE = /(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)/
        match = t.match(dateRE)
        return 0 unless match
        nums = []
        i = 1
        while i < match.length
            nums.push parseInt(match[i], 10)
            i++
        Date.UTC(nums[0], nums[1] - 1, nums[2], nums[3], nums[4], nums[5])

    #advance time according to interval in seconds
    advance_interval: (t, interval, j) ->
        @formatUTCDate(new Date(@toUTCDate(t) + j * interval * 1000))

    forceTwoDigits : (val) ->
        if val < 10
            return "0#{val}"
        return val

    formatUTCDate : (date) ->
        year = date.getUTCFullYear()
        month = @forceTwoDigits(date.getUTCMonth()+1)
        day = @forceTwoDigits(date.getUTCDate())
        hour = @forceTwoDigits(date.getUTCHours())
        minute = @forceTwoDigits(date.getUTCMinutes())
        second = @forceTwoDigits(date.getUTCSeconds())
        return "#{year}#{month}#{day}T#{hour}#{minute}#{second}"

    is_registered: (account) ->
        if account and account.registration_date == "19700101T000000"
            return false
        return true

    byteLength : (str) ->
        if !str
            return 0
        # returns the byte length of an utf8 string
        s = str.length
        i = str.length - 1

        while i >= 0
            code = str.charCodeAt(i)
            if code > 0x7f and code <= 0x7ff
                s++
            else s += 2  if code > 0x7ff and code <= 0xffff
            i--  if code >= 0xDC00 and code <= 0xDFFF #trail surrogate
            i--
        s
