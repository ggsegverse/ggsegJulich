# ggsegJulich 1.0.1

* Both atlases are rebuilt from source against the fixed `ggseg.extra`
  whole-brain pipeline (`ggseg.extra` 1.9.9.9029, `ggseg.formats`
  0.0.4.9005). Every change below follows from that rebuild.

* The subcortical atlas no longer carries a cortical hemisphere as a
  structure. Julich's `Ch_123_(Basal_Forebrain)_left` has volume index 3,
  which is also FreeSurfer's index for left cortex, so the basal forebrain
  mesh absorbed the whole left hemisphere: 74,440 vertices. The pipeline now
  moves subcortical labels off the brain-outline indices, and the largest
  mesh in the atlas is the right CA1 at 2,120 vertices.

* The lookup table gained a `type` column, so parcels are classified
  anatomically instead of by vertex count. 116 labels that are plainly
  cortex -- Area 45, Area TE 3, the insular, orbitofrontal, frontal
  opercular, intraparietal and Heschl series among them -- move out of the
  subcortical atlas and onto the surface.

* 57 structures the previous build lost are back: all hippocampal subfields
  (CA1-CA3, DG, HATA, and the para-, pre-, pro-, sub- and transsubiculum),
  all four deep cerebellar nuclei (dorsal and ventral dentate, fastigial,
  interposed), the metathalamus (CGL, CGM), the amygdalar LB, MF and VTM
  nuclei, and the entorhinal cortex.

* Region labels are no longer truncated at 28 characters, so structures
  such as `Ch_123_Basal_Forebrain_right` and the frontal opercular areas
  are named in full and stay in `core` rather than being treated as
  context.

* The atlas ships a palette you can see. The Julich release names its
  regions but gives no colours, and the previous lookup table wrote black
  for all 296, so a faithful render was a solid silhouette. The table now
  assigns each structure a hue of its own, with a structure's two sides
  sharing a colour the way FreeSurfer's tables do.

* Both atlases are simplified and smoothed after creation, which the
  pipeline no longer does on its own.

# ggsegJulich 1.0.0

* First release.
