package lysis.builder.structure;

import java.util.LinkedList;
import java.util.Stack;

import lysis.builder.structure.SwitchBlock.Case;
import lysis.instructions.LConstant;
import lysis.instructions.Opcode;
import lysis.lstructure.LBlock;
import lysis.nodes.NodeBlock;
import lysis.nodes.NodeGraph;
import lysis.nodes.NodeType;
import lysis.nodes.types.DJump;
import lysis.nodes.types.DJumpCondition;
import lysis.nodes.types.DNode;
import lysis.nodes.types.DStore;
import lysis.nodes.types.DSwitch;
import lysis.sourcepawn.SPOpcode;

public class SourceStructureBuilder {
	private NodeGraph graph_;
    private Stack<NodeBlock> joinStack_ = new Stack<NodeBlock>();

    public SourceStructureBuilder(NodeGraph graph)
    {
        graph_ = graph;
    }

    private void pushScope(NodeBlock block)
    {
        joinStack_.push(block);
    }
    private NodeBlock popScope()
    {
        return joinStack_.pop();
    }
    private boolean isJoin(NodeBlock block)
    {
        for (int i = joinStack_.size() - 1; i >= 0; i--)
        {
            if (joinStack_.elementAt(i) == block)
                return true;
        }
        return false;
    }

    private static boolean HasSharedTarget(NodeBlock pred, DJumpCondition jcc)
    {
        NodeBlock trueTarget = BlockAnalysis.EffectiveTarget(jcc.trueTarget());
        if (trueTarget.lir().numPredecessors() == 1)
            return false;
        // The true target points to the backedge of the loop. There is no logic chain in here.
        if (trueTarget.lir().loop() != null && trueTarget.lir().loop().backedge() == trueTarget.lir())
            return false;
        if (pred.lir().idominated().length > 3)
            return true;

        // Hack... sniff out the case we care about, the true target
        // probably having a conditional.
        if (trueTarget.lir().instructions().length == 2 &&
            trueTarget.lir().instructions()[0].op() == Opcode.Constant &&
            trueTarget.lir().instructions()[1].op() == Opcode.Jump)
        {
            return true;
        }

        // Because of edge splitting, there will always be at least 4
        // dominators for the immediate dominator of a shared block.
        return false;
    }

    private static LogicOperator ToLogicOp(DJumpCondition jcc)
    {
        NodeBlock trueTarget = BlockAnalysis.ConstantSettingTarget(jcc.trueTarget());
        boolean targetIsTruthy;
    	LConstant constant = (LConstant)trueTarget.lir().instructions()[0];
    	targetIsTruthy = (constant.val() == 1);

        // jump on true -> 1 == ||
        // jump on false -> 0 == &&
        // other combinations are nonsense, so assert.
        //assert((jcc.spop == SPOpcode.jnz && targetIsTruthy) ||
        //             (jcc.spop == SPOpcode.jzer && !targetIsTruthy));
        LogicOperator logicop = (jcc.spop() == SPOpcode.jnz && targetIsTruthy)
                                ? LogicOperator.Or
                                : LogicOperator.And;
        return logicop;
    }

    private static NodeBlock SingleTarget(NodeBlock block)
    {
        DJump jump = (DJump)block.nodes().last();
        return jump.target();
    }

    private static void AssertInnerJoinValidity(NodeBlock join, NodeBlock earlyExit)
    {
        DJumpCondition jcc = (DJumpCondition)join.nodes().last();
        assert(BlockAnalysis.EffectiveTarget(jcc.trueTarget()) == earlyExit ||
                     join == SingleTarget(earlyExit));
    }

    private LinkedList<Object> buildLogicChain(NodeBlock block, NodeBlock earlyExitStop, NodeBlock join)
    {
    	LinkedList<Object> retValue = new LinkedList<>();
    	retValue.add(null); // join
    	retValue.add(null); // LogicChain return
    	
        DJumpCondition jcc = (DJumpCondition)block.nodes().last();
        LogicChain chain = new LogicChain(ToLogicOp(jcc));

        // Grab the true target, which will be either the "1" or "0"
        // branch of the AND/OR expression.
        NodeBlock earlyExit = BlockAnalysis.EffectiveTarget(jcc.trueTarget());

        NodeBlock exprBlock = block;
        do
        {
            do
            {
                DJumpCondition childJcc = (DJumpCondition)exprBlock.nodes().last();
                if (BlockAnalysis.EffectiveTarget(childJcc.trueTarget()) != earlyExit)
                {
                    // Parse a sub-expression.
                    NodeBlock innerJoin = null;
                    LinkedList<Object> listRet = buildLogicChain(exprBlock, earlyExit, innerJoin);
                    LogicChain rhs = (LogicChain) listRet.get(1);
                    innerJoin = (NodeBlock) listRet.get(0);
                    AssertInnerJoinValidity(innerJoin, earlyExit);
                    chain.append(rhs);
                    exprBlock = innerJoin;
                    childJcc = (DJumpCondition)exprBlock.nodes().last();
                }
                else
                {
                    chain.append(childJcc.getOperand(0));
                }
                exprBlock = childJcc.falseTarget();
            } while (exprBlock.nodes().last().type() == NodeType.JumpCondition);

            do
            {
                // We have reached the end of a sequence - a block containing
                // a Constant and a Jump to the join point of the sequence.
                assert(exprBlock.lir().instructions()[0].op() == Opcode.Constant);

                // The next block is the join point.
                NodeBlock condBlock = SingleTarget(exprBlock);
                

                retValue.set(0, condBlock);

                // If the cond block is the tagret of the early stop, we've
                // gone a tad too far. This is the case for a simple
                // expression like (a && b) || c.
                if (earlyExitStop != null && SingleTarget(earlyExitStop) == condBlock) {
                	retValue.set(1, chain);
                	return retValue;
                }

                if(condBlock.lir().instructions()[0].op() == Opcode.Jump
                   && earlyExit == SingleTarget(condBlock))
                {
                    retValue.set(1, chain);
                    return retValue;
                }
                

                if(condBlock.nodes().first().type() == NodeType.Store) {
                    retValue.set(1, chain);
                    return retValue;
                }

                
                if(condBlock.nodes().last().type() == NodeType.Return) {
                	retValue.set(1, chain);
                	return retValue;
                }
                
                if(condBlock.nodes().last().type() == NodeType.Jump
                    && BlockAnalysis.EffectiveTarget(condBlock) == earlyExit) {
                    retValue.set(1, chain);
                    return retValue;
                }

                // This is a single block body of a loop. The logic chains ends here.
                if(condBlock.nodes().last().type() == NodeType.Jump
                    && condBlock.lir().loop() != null
                    && BlockAnalysis.GetSingleTarget(condBlock).lir() == condBlock.lir().loop()) {
                    retValue.set(1, chain);
                    return retValue;
                }
                
                DJumpCondition condJcc = (DJumpCondition)condBlock.nodes().last();
                
                // If the true connects back to the early exit stop, we're
                // done.
                if (BlockAnalysis.EffectiveTarget(condJcc.trueTarget()) == earlyExitStop) {
                	retValue.set(1, chain);
                	return retValue;
                }

                // If the true target does not have a shared target, we're
                // done parsing the whole logic chain.
                if (!HasSharedTarget(condBlock, condJcc)) {
                	retValue.set(1, chain);
                	return retValue;
                }

                // Otherwise, there is another link in the chain. This link
                // joins the existing chain to a new subexpression, which
                // actually starts hanging off the false branch of this
                // conditional.
                earlyExit = BlockAnalysis.EffectiveTarget(condJcc.trueTarget());

                // This isn't really a subexpression, but a whole new expression starting.
                if (earlyExit.lir().instructions()[0].op() != Opcode.Constant) {
                    //retValue.set(0, condJcc.falseTarget());
                    retValue.set(1, chain);
                    return retValue;
                }
                
                // Build the right-hand side of the expression.
                NodeBlock innerJoin = null;
                LinkedList<Object> listRet = buildLogicChain(condJcc.falseTarget(), earlyExit, innerJoin);
                LogicChain rhs = (LogicChain) listRet.get(1);
                innerJoin = (NodeBlock) listRet.get(0);

                // Build the full expression.
                LogicChain root = new LogicChain(ToLogicOp(condJcc));
                root.append(chain);
                root.append(rhs);
                chain = root;
                
                if(innerJoin.nodes().last().type() == NodeType.Return) {
                        retValue.set(0, innerJoin);
                	retValue.set(1, chain);
                	return retValue;
                }
                
                AssertInnerJoinValidity(innerJoin, earlyExit);

                // If the inner join's false target is a conditional, the
                // outer expression may continue.
                DJumpCondition innerJcc = (DJumpCondition)innerJoin.nodes().last();
                if (innerJcc.falseTarget().nodes().last().type() == NodeType.JumpCondition)
                {
                    exprBlock = innerJcc.falseTarget();
                    
                    // Make sure this conditional jump actually continues an expression.
                    DJumpCondition childJcc = (DJumpCondition)exprBlock.nodes().last();
                    NodeBlock exit = BlockAnalysis.EffectiveTarget(childJcc.trueTarget());
                    if (exit.lir().instructions()[0].op() != Opcode.Constant)
                    {
                        retValue.set(0, innerJoin);
                        retValue.set(1, chain);
                        return retValue;
                    }
                    break;
                }

                // Finally, the new expression block is always the early exit
                // block. It's on the "trueTarget" edge of the expression,
                // whereas incoming into this loop it's on the "falseTarget"
                // edge, but this does not matter.
                exprBlock = earlyExit;
            } while (true);
        } while (true);
    }

    private NodeBlock findJoinOfSimpleIf(NodeBlock block, DJumpCondition jcc)
    {
        assert(block.nodes().last() == jcc);
        assert(block.lir().idominated()[0] == jcc.falseTarget().lir() ||
                     block.lir().idominated()[0] == jcc.trueTarget().lir());
        assert(block.lir().idominated()[1] == jcc.falseTarget().lir() ||
                     block.lir().idominated()[1] == jcc.trueTarget().lir());
        if (block.lir().idominated().length == 2)
        {
            NodeBlock trueTarget = BlockAnalysis.EffectiveTargetNoLoop(jcc.trueTarget());
            if (trueTarget != null && jcc.trueTarget() != trueTarget)
                return jcc.trueTarget();
            NodeBlock falseTarget = BlockAnalysis.EffectiveTargetNoLoop(jcc.falseTarget());
            if (falseTarget != null && jcc.falseTarget() != falseTarget)
                return jcc.falseTarget();
            return null;
        }
        return graph_.blocks(block.lir().idominated()[2].id());
    }
    
    private ControlBlock traverseComplexIf(NodeBlock block, DJumpCondition jcc)
    {
        // Degenerate case: using || or &&, or any combination thereof,
        // will generate a chain of n+1 conditional blocks, where each
        // |n| has a target to a shared "success" block, setting a
        // phony variable. We decompose this giant mess into the intended
        // sequence of expressions.
        NodeBlock join = null;
        LinkedList<Object> listRet = buildLogicChain(block, null, join);
        LogicChain chain = (LogicChain) listRet.get(1);
        join = (NodeBlock) listRet.get(0);

        // Complex if with no body. Someone wants to fool us?
        // if(cond && !cond) {}
        if(join.nodes().last().type() == NodeType.Jump)
        {
            return new IfBlock(block, false, chain, null, null, null);
        }
        
        // LogicChain assigned to a variable?
        // new bla = cond1 && cond2;
        if(join.nodes().first().type() == NodeType.Store)
        {
            DStore store_ = (DStore)join.nodes().first();
            store_.setLogicChain(chain);
            return new StatementBlock(block, traverseBlock(graph_.blocks(join.lir().id())));
        }
        
        // complex return conditions
        // return cond1 && cond2;
        if(join.nodes().last().type() == NodeType.Return)
        {
            return new ReturnBlock(block, chain);
        }
        
        DJumpCondition finalJcc = (DJumpCondition)join.nodes().last();
        assert(finalJcc.spop() == SPOpcode.jzer);
      
        // The final conditional should have the normal dominator
        // properties: 2 or 3 idoms, depending on the number of arms.
        // Because of critical edge splitting, we may have 3 idoms
        // even if there are only actually two arms.
        NodeBlock joinBlock = findJoinOfSimpleIf(join, finalJcc);

        // If an AND chain reaches its end, the result is 1. jzer tests
        // for zero, so this is effectively testing (!success).
        // If an OR expression reaches its end, the result is 0. jzer
        // tests for zero, so this is effectively testing if (failure).
        //
        // In both cases, the true target represents a failure, so flip
        // the targets around.
        NodeBlock trueBlock = finalJcc.falseTarget();
        NodeBlock falseBlock = finalJcc.trueTarget();

        // If there is no join block, both arms terminate control flow,
        // eliminate one arm and use the other as a join point.
        if (joinBlock == null)
            joinBlock = falseBlock;

        // If the false target is equivalent to the join point, eliminate
        // it.
        if (falseBlock == joinBlock)
            falseBlock = null;

        // If the true target is equivalent to the join point, promote
        // the false target to the true target and undo the inversion.
        boolean invert = false;
        if (trueBlock == joinBlock)
        {
            trueBlock = falseBlock;
            falseBlock = null;
            invert ^= true;
        }
        
        if (join.lir().idominated().length == 2 ||
            BlockAnalysis.EffectiveTarget(falseBlock) == joinBlock)
        {
            if (join.lir().idominated().length == 3)
                joinBlock = BlockAnalysis.EffectiveTarget(falseBlock);

            // One-armed structure.
            pushScope(joinBlock);
            ControlBlock trueArm1 = traverseBlock(trueBlock);
            popScope();

            ControlBlock joinArm1 = traverseJoin(joinBlock);
            return new IfBlock(block, invert, chain, trueArm1, joinArm1);
        }

        //assert(join.lir().idominated().length == 3);

        pushScope(joinBlock);
        ControlBlock trueArm2 = traverseBlock(trueBlock);
        ControlBlock falseArm = traverseBlock(falseBlock);
        popScope();

        ControlBlock joinArm2 = traverseJoin(joinBlock);
        return new IfBlock(block, invert, chain, trueArm2, falseArm, joinArm2);
    }

    private ControlBlock traverseIf(NodeBlock block, DJumpCondition jcc)
    {
        if (HasSharedTarget(block, jcc))
            return traverseComplexIf(block, jcc);

        NodeBlock trueTarget = (jcc.spop() == SPOpcode.jzer) ? jcc.falseTarget() : jcc.trueTarget();
        NodeBlock falseTarget = (jcc.spop() == SPOpcode.jzer) ? jcc.trueTarget() : jcc.falseTarget();
        NodeBlock joinTarget = findJoinOfSimpleIf(block, jcc);

        // If there is no join block (both arms terminate control flow),
        // eliminate one arm and use the other as a join point.
        if (joinTarget == null)
            joinTarget = falseTarget;

        // If the false target is equivalent to the join point, eliminate
        // it.
        if (falseTarget == joinTarget || BlockAnalysis.EffectiveTargetNoLoop(falseTarget) == joinTarget)
            falseTarget = null;

        // If the true target is equivalent to the join point, promote
        // the false target to the true target and undo the inversion.
        boolean invert = false;
        if (trueTarget == joinTarget || BlockAnalysis.EffectiveTargetNoLoop(trueTarget) == joinTarget)
        {
            trueTarget = falseTarget;
            falseTarget = null;
            invert ^= true;
        }

        if (BlockAnalysis.EffectiveTargetNoLoop(trueTarget) == null)
            trueTarget = null;
        
        if (BlockAnalysis.EffectiveTargetNoLoop(joinTarget) == null)
        {
            trueTarget = joinTarget;
            joinTarget = null;
            invert ^= true;
        }
        
        // If there is always a true target and a join target.
        ControlBlock trueArm = null;
        // TODO empty if / no true target?
        if(trueTarget != null)
        {
        	pushScope(joinTarget);
        	trueArm = traverseBlock(trueTarget);
        	popScope();
        }

        ControlBlock joinArm = traverseJoin(joinTarget);
        if (falseTarget == null)
            return new IfBlock(block, invert, trueArm, joinArm);

        pushScope(joinTarget);
        ControlBlock falseArm = traverseBlock(falseTarget);
        popScope();

        return new IfBlock(block, invert, trueArm, falseArm, joinArm);
    }

    private LinkedList<Object> findLoopJoinAndBody(NodeBlock header, NodeBlock effectiveHeader)
    {
        assert(effectiveHeader.lir().numSuccessors() >= 1);

        LinkedList<Object> retList = new LinkedList<>();
        retList.add(null); // ControlType controlType = null;
        retList.add(null); // NodeBlock join = null;
        retList.add(null); // NodeBlock body = null;
        retList.add(null); // NodeBlock cond = null;
        
        LBlock succ1 = effectiveHeader.lir().getSuccessor(0);
        LBlock succ2 = null;
        // We only have one successor, if the last node is a Jump instead of a JumpCondition.
        if(effectiveHeader.lir().numSuccessors() == 2)
        {
            succ2 = effectiveHeader.lir().getSuccessor(1);
        }

        if (succ1.loop() == header.lir() && succ2 == null
           || (succ2 != null && (
                succ1.loop() != header.lir() || succ2.loop() != header.lir())))
        {
            assert(succ1.loop() == header.lir() || (succ2 != null && succ2.loop() == header.lir()));
            if (succ1.loop() != header.lir())
            {
            	retList.set(1, graph_.blocks(succ1.id()));
            	retList.set(2, succ2 != null ? graph_.blocks(succ2.id()) : null);
            }
            else
            {
            	retList.set(1, succ2 != null ? graph_.blocks(succ2.id()) : null);
            	retList.set(2, graph_.blocks(succ1.id()));
            }
            retList.set(3, header);

            // If this is a self-loop, it is more correct to decompose it
            // to a do-while loop. This may not be source accurate in the
            // case of something like |while (x);| but it catches many more
            // source-accurate cases.
            if (header == effectiveHeader &&
                BlockAnalysis.GetEmptyTarget((NodeBlock) retList.get(2)) == header)
            {
            	retList.set(2, null);
            	retList.set(0, ControlType.DoWhileLoop);
                return retList;
            }

            retList.set(0, ControlType.WhileLoop);
            return retList;
        }
        else
        {
            // Neither successor of the header exits the loop, so this is
            // probably a do-while loop. For now, assume it's simple.
            //assert(header == effectiveHeader);
            LBlock backedge = header.lir().backedge();
            if (BlockAnalysis.GetEmptyTarget(graph_.blocks(backedge.id())) == header)
            {
                // Skip an empty block sitting in between the backedge and
                // the condition.
                assert(backedge.numPredecessors() == 1);
                backedge = backedge.getPredecessor(0);
            }

            assert(backedge.numSuccessors() == 1 || backedge.numSuccessors() == 2);
            succ1 = backedge.getSuccessor(0);
            if (backedge.numSuccessors() > 1)
                succ2 = backedge.getSuccessor(1);
            else
                succ2 = null;

            retList.set(2, header);
            retList.set(3, graph_.blocks(backedge.id()));
            if (succ1.loop() != header.lir())
            {
            	retList.set(1, graph_.blocks(succ1.id()));
            }
            else if (succ2 != null)
            {
                assert(succ2.loop() != header.lir());
                retList.set(1, graph_.blocks(succ2.id()));
            }
            else
            {
                retList.set(1, null);
            }
            retList.set(0, ControlType.DoWhileLoop);
            return retList;
        }
    }

    private ControlBlock traverseLoop(NodeBlock block)
    {
        DNode last = block.nodes().last();

        NodeBlock effectiveHeader = block;
        LogicChain chain = null;
        if (last.type() == NodeType.JumpCondition)
        {
            DJumpCondition jcc = (DJumpCondition)last;
            if (HasSharedTarget(block, jcc)) {
                LinkedList<Object> listRet = buildLogicChain(block, null, effectiveHeader);
                chain = (LogicChain) listRet.get(1);
                effectiveHeader = (NodeBlock) listRet.get(0);
            }
        }

        last = effectiveHeader.nodes().last();
        
        if (last.type() == NodeType.Switch)
        {
            SwitchBlock switchBlock = (SwitchBlock)traverseSwitch(block, (DSwitch)last);
            return new WhileLoop(ControlType.DoWhileLoop, effectiveHeader, switchBlock, null);
        }
        
        assert(last.type() == NodeType.JumpCondition || last.type() == NodeType.Jump);

        if (last.type() == NodeType.JumpCondition || last.type() == NodeType.Jump)
        {
            // Assert that the backedge is a straight jump.
            assert(BlockAnalysis.GetSingleTarget(graph_.blocks(block.lir().backedge().id())) == block);

            LinkedList<Object> byValueWorkaround = findLoopJoinAndBody(block, effectiveHeader);
            ControlType type = (ControlType) byValueWorkaround.get(0);
            NodeBlock join = (NodeBlock) byValueWorkaround.get(1);
            NodeBlock body = (NodeBlock) byValueWorkaround.get(2);
            NodeBlock cond = (NodeBlock) byValueWorkaround.get(3);
            
            //ControlType type = findLoopJoinAndBody(block, effectiveHeader, join, body, cond);
            ControlBlock joinArm = null;
            if (join != null)
            {
                pushScope(block);
                pushScope(cond);
                joinArm = traverseJoin(join);
                popScope();
                popScope();
            }

            ControlBlock bodyArm = null;
            if (body != null)
            {
                pushScope(block);
                pushScope(cond);
                bodyArm = traverseBlockNoLoop(body);
                popScope();
                popScope();
            }

            if (chain != null && type != ControlType.DoWhileLoop)
                return new WhileLoop(type, chain, bodyArm, joinArm);
            return new WhileLoop(type, cond, bodyArm, joinArm);
        }

        return null;
    }

    private ControlBlock traverseSwitch(NodeBlock block, DSwitch switch_)
    {
        LinkedList<LBlock> dominators = new LinkedList<LBlock>();
        for (int i = 0; i < block.lir().idominated().length; i++)
            dominators.add(block.lir().idominated()[i]);

        dominators.remove(switch_.defaultCase());
        for (int i = 0; i < switch_.numCases(); i++)
            dominators.remove(switch_.getCase(i).target);

        NodeBlock join = null;
        if (dominators.size() > 0)
        {
            assert(dominators.size() == 1);
            join = graph_.blocks(dominators.get(dominators.size() - 1).id());
        }

        // Don't run over blocks again, we've already passed before the switch.
        ControlBlock joinArm = null;
        if (join != null && BlockAnalysis.EffectiveTarget(join).lir().id() > block.lir().id())
            joinArm = traverseJoin(join);

        pushScope(block);
        pushScope(join);
        LinkedList<Case> cases = new LinkedList<SwitchBlock.Case>();
        NodeBlock defaultBlock = graph_.blocks(switch_.defaultCase().id());
        ControlBlock defaultArm = null;
        if (!isJoin(defaultBlock))
            defaultArm = traverseBlock(defaultBlock);
        pushScope(defaultBlock);
        for (int i = 0; i < switch_.numCases(); i++)
        {
            ControlBlock arm = traverseBlock(graph_.blocks(switch_.getCase(i).target.id()));
            cases.add(new SwitchBlock.Case(switch_.getCase(i).values(), arm));
        }
        popScope();
        popScope();
        popScope();

        return new SwitchBlock(block, defaultArm, cases, joinArm);
    }

    private ControlBlock traverseJoin(NodeBlock block)
    {
        if (isJoin(block))
            return null;
        return traverseBlock(block);
    }

    private ControlBlock traverseBlockNoLoop(NodeBlock block)
    {
        DNode last = block.nodes().last();

        if (last.type() == NodeType.JumpCondition)
            return traverseIf(block, (DJumpCondition)last);

        if (last.type() == NodeType.Jump)
        {
            DJump jump = (DJump)last;
            //NodeBlock target = BlockAnalysis.EffectiveTarget(jump.target());
            NodeBlock target = jump.target();

            ControlBlock next = null;
            if (!isJoin(target))
                next = traverseBlock(target);

            return new StatementBlock(block, next);
        }

        if (last.type() == NodeType.Switch)
            return traverseSwitch(block, (DSwitch)last);

        assert(last.type() == NodeType.Return);
        return new ReturnBlock(block);
    }

    private ControlBlock traverseBlock(NodeBlock block)
    {
        if (block.lir().backedge() != null)
            return traverseLoop(block);

        return traverseBlockNoLoop(block);
    }

    public ControlBlock build()
    {
        return traverseBlock(graph_.blocks(0));
    }
}
