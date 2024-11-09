local Server = {}

function Server:GetJobs()
  local jobs = ESX.GetJobs()
  local availableJobs = {}

  for k, v in pairs(jobs) do
    if v.whitelisted == false then
      availableJobs[#availableJobs + 1] = {label = v.label, name = k}
    end
  end

  return availableJobs
end

function Server:IsJobAvailable(job)
  local jobs = ESX.GetJobs()
  local JobToCheck = jobs[job]

  return not JobToCheck.whitelisted
end

function Server:IsNearCentre(player)
  local Ped = GetPlayerPed(player)
  local PedCoords = GetEntityCoords(Ped)

  local Zones = Config.Zones

  for i = 1, #Zones, 1 do
    local distance = #(PedCoords - Zones[i])

    if distance < Config.DrawDistance then
      return true
    end
  end

  return false
end

ESX.RegisterServerCallback('esx_joblisting:setJob', function(source, cb, job)
  local xPlayer = ESX.GetPlayerFromId(source)
  local IsNearCentre = Server:IsNearCentre(source)
  local IsJobAvailable = Server:IsJobAvailable(job)

  if xPlayer and IsNearCentre and IsJobAvailable then
    if ESX.DoesJobExist(job, 0) then
      xPlayer.setJob(job, 0)
      cb(true)
      return
    else
      print("[^1ERROR^7] Tried Setting User ^5".. source .. "^7 To Invalid Job - ^5"..job .."^7!")
      cb(false)
      return
    end
  else
    print("[^3WARNING^7] User ^5".. source .. "^7 Attempted to Exploit ^5`esx_joblisting:setJob`^7!")
    cb(false)
    return
  end
  cb(true)
end)

ESX.RegisterServerCallback('esx_joblisting:getJobsList', function(source, cb)
  local jobs = Server:GetJobs()
  cb(jobs)
end)