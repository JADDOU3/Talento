package org.example.backend.service;


import org.example.backend.Dto.kit.AddToChildCollectionDto;
import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.KitRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class KitService {

    @Autowired
    private KitRepo kitrepo;
    @Autowired
    private ChildService childService;
    @Autowired
    private ChildRepo childRepo;

    public Kit createKit(CreateKitDto createKitDto){
        Kit kit = new Kit();
        kit.setName(createKitDto.getName());
        kit.setDescription(createKitDto.getDescription());

        if(createKitDto.getPrice() == null)
            kit.setPrice(0.0);
        else
            kit.setPrice(createKitDto.getPrice());

        kit.setCreatedAt(LocalDateTime.now());
        kit.setType(createKitDto.getType());
        kit.setMindset(createKitDto.getMindset());
        kit.setImageURL(createKitDto.getImageURL());
        kit.setKitItems(createKitDto.getKitItems());

        return kitrepo.save(kit);
    }

    public Kit getKitById(int id){
        return kitrepo.findById(id).orElse(null);
    }

    public  Kit updateKit(UpdateKitDto updateKitDto){
        Kit kit = kitrepo.findById(updateKitDto.getId()).orElse(null);
        if(kit == null)
            return null;
        if(updateKitDto.getName() != null) kit.setName(updateKitDto.getName());
        if(updateKitDto.getDescription() != null) kit.setDescription(updateKitDto.getDescription());
        if(updateKitDto.getType() != null) kit.setType(updateKitDto.getType());
        if(updateKitDto.getMindset() != null) kit.setMindset(updateKitDto.getMindset());
        if(updateKitDto.getPrice() != null) kit.setPrice(updateKitDto.getPrice());
        if(updateKitDto.getImageURL() != null) kit.setImageURL(updateKitDto.getImageURL());
        if(updateKitDto.getKitItems() != null) kit.setKitItems(updateKitDto.getKitItems());

        return kitrepo.save(kit);

    }

    public String deleteKit(int id){
        Kit kit = kitrepo.findById(id).orElse(null);
        if(kit == null)
            return "Kit not found";
        kitrepo.delete(kit);
        return "Kit deleted";
    }

    public List<Kit> getAllKits(){
        return kitrepo.findAll();
    }


    public List<Kit> getKitsByChildId(int id) {
        return kitrepo.findByChildId(id);
    }

    public Kit addToChildsCollection(AddToChildCollectionDto addToChildCollectionDto) {
        Kit kit = kitrepo.findById(addToChildCollectionDto.getKitId()).orElse(null);
        kit.setChild(childService.getChildById(addToChildCollectionDto.getChildId()));
        kit.getChild().getKits().add(kit);
        childRepo.save(kit.getChild());
    return kitrepo.save(kit);
    }
}
