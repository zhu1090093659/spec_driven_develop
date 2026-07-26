# Task Dependency Graph

```mermaid
graph TD
    subgraph Phase1 [Phase 1: Foundation and Guard]
        subgraph P1B1 [Batch P1-B1: batch/p1-b1-foundation-guard]
            subgraph P1W1 [Wave 1 - parallel lanes]
                T1_4["T1.4 validate.sh + fixture (Lane A)"]
                T1_5["T1.5 AGENTS.md repair (Lane A)"]
                T1_1["T1.1 stale refs (Lane B)"]
                T1_2["T1.2 10-check relocation (Lane B)"]
                T1_3["T1.3 hygiene + .gitignore (Lane C)"]
                T1_4 --> T1_5
            end
        end
    end

    subgraph Phase2 [Phase 2: Orchestrator-Centric Execution Model]
        subgraph P2B1 [Batch P2-B1: batch/p2-b1-orchestrator-review-loop]
            T2_1["T2.1 code-reviewer.md (W1, Lane A)"]
            subgraph P2W2 [Wave 2 - parallel]
                T2_2["T2.2 SKILL Phase 5 (A1)"]
                T2_3["T2.3 parallel-protocol (A1)"]
                T2_4["T2.4 behavioral-rules rule 18 (A2)"]
                T2_5["T2.5 task-executor (A2)"]
                T2_6["T2.6 task-architect (A2)"]
            end
            subgraph P2W3 [Wave 3 - parallel]
                T2_7a["T2.7a manifests+loader+CLAUDE (B1)"]
                T2_7b["T2.7b README mirrors (B2)"]
            end
            T2_1 --> T2_2 & T2_4
            T2_2 --> T2_3
            T2_4 --> T2_5 --> T2_6
            T2_3 --> T2_7a & T2_7b
            T2_6 --> T2_7a & T2_7b
        end
    end

    subgraph Phase3 [Phase 3: Prompt Single-Sourcing + Conciseness]
        subgraph P3B1 [Batch P3-B1: batch/p3-b1-prompt-single-sourcing]
            subgraph P3W1 [Wave 1 - parallel, exclusive file ownership]
                T3_1["T3.1 SKILL.md (A)"]
                T3_2["T3.2 github-integration (B1)"]
                T3_3["T3.3 adaptive-control + parallel-protocol (B2)"]
                T3_4["T3.4 behavioral-rules hedge (C)"]
                T3_5["T3.5 agents slim (C)"]
                T3_6["T3.6 templates + format freeze (D)"]
                T3_8["T3.8 satellite skills conciseness (F)"]
                T3_4 --> T3_5
            end
            T3_7["T3.7 audit gate (W2, Lane E)"]
            T3_1 & T3_2 & T3_3 & T3_5 & T3_6 & T3_8 --> T3_7
        end
    end

    subgraph Phase4 [Phase 4: Command Surface Removal + Distribution]
        subgraph P4B1 [Batch P4-B1: batch/p4-b1-command-surface-removal]
            subgraph P4W1 [Wave 1 - parallel]
                T4_1["T4.1 delete commands/ 5 surfaces (A)"]
                T4_2["T4.2 install-agents.sh (B)"]
            end
        end
    end

    subgraph Phase5 [Phase 5: Docs Consolidation + Release]
        subgraph P5B1 [Batch P5-B1: batch/p5-b1-release-1-15-0]
            subgraph P5W1 [Wave 1 - parallel]
                T5_1["T5.1 README reconciliation (A)"]
                T5_2["T5.2 AGENTS/CLAUDE final (B)"]
            end
            T5_3["T5.3 version 1.15.0 + release (W2)"]
            T5_1 --> T5_3
            T5_2 --> T5_3
        end
    end

    P1B1 --> P2B1 --> P3B1 --> P4B1 --> P5B1
```

**Critical path**: T1.4 → T2.1 → T2.2 → T2.3/T2.6 → T2.7 → T3.1 → T3.7 → T4.1 → T5.1 → T5.3.

Phase gates P1→P2→P3→P4→P5 are hard (sequential batches). Within phases, lanes with exclusive file ownership run in parallel waves. The P2 chain is the longest single-phase segment because writer-model prose must land coherently before registration.
