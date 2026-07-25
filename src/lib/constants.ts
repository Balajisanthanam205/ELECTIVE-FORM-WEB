export const SUBJECTS = [
  {
    code: "VD22704",
    name: "Embedded System Simulation",
    fullLabel: "VD22704 Embedded System Simulation",
  },
  {
    code: "VD22702",
    name: "Artificial Neural Networks",
    fullLabel: "VD22702 Artificial Neural Networks",
  },
  {
    code: "VD22712",
    name: "Standards for Electronics and Communication Engineers",
    fullLabel: "VD22712 Standards for Electronics and Communication Engineers",
  },
  {
    code: "VD22705",
    name: "Hardware Modeling and Analysis using EDA Tool",
    fullLabel: "VD22705 Hardware Modeling and Analysis using EDA Tool",
  },
] as const;

export const SECTIONS = [
  "A",
  "B",
  "C",
] as const;

export const MAX_SEATS = 2;
export const COLLEGE_EMAIL_DOMAIN = "@svce.ac.in";

export type SubjectCode = (typeof SUBJECTS)[number]["code"];
export type Section = (typeof SECTIONS)[number];
