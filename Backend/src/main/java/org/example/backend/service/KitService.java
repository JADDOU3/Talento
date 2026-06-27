package org.example.backend.service;

import org.example.backend.Dto.kit.AddToChildCollectionDto;
import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.Child;
import org.example.backend.model.ChildKit;
import org.example.backend.model.Kit;
import org.example.backend.repo.ChildKitRepo;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.KitRepo;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.repo.mindset.MindsetRepo;
import org.example.backend.service.community.S3Service;
import org.example.backend.util.enums.Type;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class KitService {

    @Autowired
    private KitRepo kitRepo;

    @Autowired
    private ChildRepo childRepo;

    @Autowired
    private ChildKitRepo childKitRepo;

    @Autowired
    private MindsetRepo mindsetRepo;

    @Autowired
    private S3Service s3Service;

    public Kit createKit(CreateKitDto createKitDto) {
        Kit kit = new Kit();
        kit.setName(createKitDto.getName());
        kit.setDescription(createKitDto.getDescription());
        kit.setPrice(createKitDto.getPrice() != null ? createKitDto.getPrice() : 0.0);
        kit.setCreatedAt(LocalDateTime.now());
        kit.setType(createKitDto.getType());

        if (createKitDto.getMindsetId() != null) {
            Mindset mindset = mindsetRepo.findById(createKitDto.getMindsetId()).orElse(null);
            kit.setMindset(mindset);
        }

        kit.setImageKey(createKitDto.getImageKey());
        kit.setKitItems(createKitDto.getKitItems());
        kit.setRating(createKitDto.getRating() != null ? createKitDto.getRating() : 0);
        kit.setAge(createKitDto.getAge() != null ? createKitDto.getAge() : 1);
        return kitRepo.save(kit);
    }

    public Kit getKitById(int id) {
        return kitRepo.findById(id).orElse(null);
    }

    public Kit updateKit(UpdateKitDto updateKitDto) {
        Kit kit = kitRepo.findById(updateKitDto.getId()).orElse(null);
        if (kit == null) return null;
        if (updateKitDto.getName() != null) kit.setName(updateKitDto.getName());
        if (updateKitDto.getDescription() != null) kit.setDescription(updateKitDto.getDescription());
        if (updateKitDto.getType() != null) kit.setType(updateKitDto.getType());

        if (updateKitDto.getMindsetId() != null) {
            Mindset mindset = mindsetRepo.findById(updateKitDto.getMindsetId()).orElse(null);
            kit.setMindset(mindset);
        }

        if (updateKitDto.getPrice() != null) kit.setPrice(updateKitDto.getPrice());
        if (updateKitDto.getImageKey() != null) kit.setImageKey(updateKitDto.getImageKey());
        if (updateKitDto.getKitItems() != null) kit.setKitItems(updateKitDto.getKitItems());
        if (updateKitDto.getRating() != null) kit.setRating(updateKitDto.getRating());
        if (updateKitDto.getAge() != null) kit.setAge(updateKitDto.getAge());
        return kitRepo.save(kit);
    }

    public String deleteKit(int id) {
        Kit kit = kitRepo.findById(id).orElse(null);
        if (kit == null) return "Kit not found";
        kitRepo.delete(kit);
        return "Kit deleted";
    }

    public Page<Kit> getAllKits(Pageable pageable) {
        return kitRepo.findAll(pageable);
    }

    public List<ChildKit> getKitsByChildId(int childId) {
        return childKitRepo.findByChildId(childId);
    }

    @Transactional
    public ChildKit addToChildsCollection(AddToChildCollectionDto dto) {
        Kit kit = kitRepo.findById(dto.getKitId())
                .orElseThrow(() -> new RuntimeException("Kit not found"));
        Child child = childRepo.findById(dto.getChildId())
                .orElseThrow(() -> new RuntimeException("Child not found"));

        if (childKitRepo.existsByChildAndKit(child, kit)) {
            throw new RuntimeException("Child already owns this kit");
        }

        ChildKit childKit = new ChildKit();
        childKit.setKit(kit);
        childKit.setChild(child);
        childKit.setAcquiredAt(LocalDateTime.now());
        childKit.setIsSelected(false);
        return childKitRepo.save(childKit);
    }

    @Transactional
    public String removeFromChildsCollection(int childId, int kitId) {
        Child child = childRepo.findById(childId).orElseThrow(() -> new RuntimeException("Child not found"));
        Kit kit = kitRepo.findById(kitId).orElseThrow(() -> new RuntimeException("Kit not found"));
        if (!childKitRepo.existsByChildAndKit(child, kit)) {
            return "Kit not in child's collection";
        }
        childKitRepo.deleteByChildAndKit(child, kit);
        return "Kit removed from collection";
    }

    public List<Kit> getKitsByType(Type type) {
        return kitRepo.findByType(type);
    }

    public List<Kit> getKitsByMindset(int mindsetId) {
        Mindset mindset = mindsetRepo.findById(mindsetId).orElse(null);
        if (mindset == null) return List.of();
        return kitRepo.findByMindset(mindset);
    }

    public List<Kit> searchKitsByName(String keyword) {
        return kitRepo.findByNameContainingIgnoreCase(keyword);
    }
}