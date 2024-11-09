local menuIsShowed,isNear, TextUIdrawing = false, false, false

function ShowJobListingMenu()
  menuIsShowed = true
  ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
    local elements = {{unselectable = "true", title = TranslateCap('job_center'), icon = "fas fa-briefcase"}}

    for i = 1, #(jobs) do
      elements[#elements + 1] = {title = jobs[i].label, name = jobs[i].name}
    end

    ESX.OpenContext("right", elements, function(menu, SelectJob)
      TriggerServerEvent('esx_joblisting:setJob', SelectJob.name)
      ESX.CloseContext()
      ESX.ShowNotification(TranslateCap('new_job', SelectJob.title), "success")
      menuIsShowed = false
      TextUIdrawing = false
    end, function()
      menuIsShowed = false
      TextUIdrawing = false
    end)
  end)
end

-- Activate menu when player is inside marker, and draw markers

-- Create blips
if Config.Blip.Enabled then
  CreateThread(function()
    for i = 1, #Config.Zones, 1 do
      local blip = AddBlipForCoord(Config.Zones[i])

      SetBlipSprite(blip, Config.Blip.Sprite)
      SetBlipDisplay(blip, Config.Blip.Display)
      SetBlipScale(blip, Config.Blip.Scale)
      SetBlipColour(blip, Config.Blip.Colour)
      SetBlipAsShortRange(blip, Config.Blip.ShortRange)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(TranslateCap('blip_text'))
      EndTextCommandSetBlipName(blip)

      ESX.CreatePoint({
        coords = Config.Zones[i],
        distance = Config.DrawDistance,
        onExit = function()
          ESX.HideUI()
          isNear = false
          TextUIdrawing = false
        end,
        nearby = function(self)
         DrawMarker(Config.MarkerType, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z,
            Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
  
          isNear = self.currentDistance <= 2.0
  
          if isNear and not TextUIdrawing then
            ESX.TextUI(TranslateCap('access_job_center', ESX.GetInteractKey()))
            TextUIdrawing = true
          else
            if not isNear and TextUIdrawing then
              ESX.HideUI()
              TextUIdrawing = false
            end
          end
        end
      })
    end
  end)
end

ESX.RegisterInteraction("open_joblisting", function()
  ShowJobListingMenu()
end, function()
  return isNear and not menuIsShowed
end)