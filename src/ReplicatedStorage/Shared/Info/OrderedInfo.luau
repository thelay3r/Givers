local IgnoreList: {string} = {[1] = true}
local OrderedConstants: {[string]: {maxCount: number, values: {{[string]: number}}, datastore: OrderedDataStore?}} = {}

OrderedConstants['Coins'] = {maxCount = 50, values = {}, datastore = nil}

return {
    ['IgnoreList'] = IgnoreList,
    ['OrderedConstants'] = OrderedConstants
}