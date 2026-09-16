# ggsegJulich 1.0.0.9000

* Regions are split between the two atlases by anatomy rather than by how
  much surface they cover. The previous build's lookup table had no usable
  `type` column, so the pipeline fell back to counting surface vertices and
  filed roughly 130 cortical parcels - the insular, orbitofrontal and
  parietal series among them - as subcortical. `julich_cortical()` now
  holds 125 regions over 252 rows and `julich_subcortical()` 22 over 44.
* The eight deep cerebellar nuclei (dorsal and ventral dentate, interposed
  and fastigial, both sides) are in `julich_subcortical()`, where they read
  as nuclei. They are anatomically cerebellar, but a ggsegverse cerebellar
  atlas is a SUIT flatmap of the cerebellar cortical sheet and these nuclei
  sit in the cerebellar white matter. Previous builds dropped them.
* `Area Id5 (Insula)` and `Ch 123 (Basal Forebrain)` were classified one
  way on the left and the other on the right, which put each structure in
  both atlases. Both are now whole, the insular area in cortex and the
  basal forebrain nuclei in subcortex.
* `IF (Amygdala)` is the one label of 296 in neither atlas: it never wins
  the maximum probability map, so it has no voxels to draw.
* `Area Fo1 (OFC)` and `Area Fo2 (OFC)` sit on the midline and their
  right-hemisphere labels reach left-hemisphere surface vertices, so each
  has a third row. That is why 125 regions come to 252 rather than 250 rows.
* Both atlases have a real palette again: one hue per structure, shared by
  its two hemispheres, with cortical and subcortical structures drawn from
  the ramp separately.
* The subcortical geometry is polished in two passes. The grey brain
  outline the structures are read against keeps its ventricles and
  temporal horns, where a single pass over the whole atlas closed them;
  the structures themselves read as smooth nuclei rather than as voxel
  staircases.
