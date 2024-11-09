local JobCentre = {}

JobCentre.isNear = false
JobCentre.menuOpen = false
JobCentre.TextUIActive = false

function JobCentre:GetJobs()
  local promise = promise:new()

  ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
    promise:resolve(jobs)
  end)

  Citizen.Await(promise)
  return promise.value
end

function JobCentre:InsertJobs()
  local jobs = self:GetJobs()
  local elements = {}
  local unemployed = {}

  for i=1, #jobs, 1 do
    local job = jobs[i]
    if job.name ~= 'unemployed' then
      elements[#elements + 1] = {
        label = job.label,
        value = job.name
      }
    else
      unemployed = {
        label = job.label,
        value = job.name
      }
    end
  end

  table.sort(elements, function(a, b)
    return a.label < b.label
  end)

  table.insert(elements, 1, unemployed)

  return elements
end

function JobCentre:OnSelect(value)
  ESX.TriggerServerCallback('esx_joblisting:setJob', function(isJob)
    if not isJob then
      ESX.ShowNotification('Unable to employ you as a '.. value, "error")
      return
    end
    ESX.ShowNotification('You are now employed as a '.. value, "success")
  end, value)
end

function JobCentre:Close(menu)
  menu.close()
  self.menuOpen = false
end

function JobCentre:ShowMenu()
  self.menuOpen = true

  local elements = self:InsertJobs()

  ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'joblisting', {
    title = 'Job Centre',
    align = 'top-left',
    elements = elements
  }, function(data, menu)
    self:OnSelect(data.current.value)
    self:Close(menu)
  end, function(_, menu)
    self:Close(menu)
  end)
end

function JobCentre:CreateBlip(coords)
  local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

  SetBlipSprite(blip, Config.Blip.Sprite)
  SetBlipDisplay(blip, Config.Blip.Display)
  SetBlipScale(blip, Config.Blip.Scale)
  SetBlipColour(blip, Config.Blip.Colour)
  SetBlipAsShortRange(blip, Config.Blip.ShortRange)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName(TranslateCap('blip_text'))
  EndTextCommandSetBlipName(blip)
end

function JobCentre:TextUI(text)
  ESX.TextUI(text)
  self.TextUIActive = true
end

function JobCentre:HideTextUI()
  ESX.HideUI()
  self.TextUIActive = false
end

function JobCentre:ToggleTextUI()
  if self.isNear and not self.TextUIActive then
    self:TextUI(TranslateCap('access_job_center', ESX.GetInteractKey()))
  else
    if not self.isNear and self.TextUIActive then
      self:HideTextUI()
    end
  end
end

function JobCentre:InsidePoint(distance, coords)
  self.isNear = distance < (Config.ZoneSize.x / 2)

  DrawMarker(Config.MarkerType, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z,
  Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 200, false, true, 2, false, false, false, false)

  self:ToggleTextUI()
end

function JobCentre:LeavePoint()
  self.isNear = false
  self:HideTextUI()
end

function JobCentre:CreatePoint(coords)
  ESX.Point:new({
    coords = coords,
    distance = Config.DrawDistance,
    inside = function(point)
      self:InsidePoint(point.currDistance, point.coords)
    end,
    leave = function()
      self:LeavePoint()
    end
  })
end

CreateThread(function()
  for i=1, #Config.Zones, 1 do
    local coords = Config.Zones[i]
    if Config.Blip.Enabled then
      JobCentre:CreateBlip(coords)
    end
    JobCentre:CreatePoint(coords)
  end
end)

ESX.RegisterInteraction("open_joblisting", function()
  JobCentre:ShowMenu()
end, function()
  return JobCentre.isNear and not JobCentre.menuOpen
end)