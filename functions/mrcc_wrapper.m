function [ca_mat, cons_vec, all_part] = mrcc_wrapper(mat, samples,flag,ROIlabels)

narginchk(2,5)

% mat -       a covariance matrix
% samples -   number of initial partitions (recommened at least 1000)
% path2code - path to directory that contains the Hierarchical Consensus
%               and GenLouvain packages.
% flag -      show the mrcc consensus plot.
% cmap -      colormap

% generate initial sweep of partitions
S = eventSamples(mat, samples);

% identify a consensus community structure and hierarchical consensus
[cons_vec, Tree_mrcc] = hierarchicalConsensus(S);

% if isempty(Tree_mrcc)
[~,ord] = sort(cons_vec);

% get a coclassification (agreement) matrix from the partition set.
ca_mat = coclassificationMatrix(S);

% get partitions for all spatial scales in the dendrogram
[all_part, ~] = allPartitions(cons_vec, Tree_mrcc);

if exist('flag','var') && flag == 1
    % Visualize the agreement matrix and the hierarchical community structure
    figure(...
        'units','inches',...
        'position',[1 1 7.5 6],...
        'paperpositionmode','auto');

    if isempty(Tree_mrcc) || length(unique(all_part))==1
        imagesc(ca_mat,[0 1]); axis square; colorbar;
        xticks(1:1:length(ROIlabels)); xticklabels(ROIlabels(ord)); xtickangle(90);
        yticks(1:1:length(ROIlabels)); yticklabels(ROIlabels(ord)); 
        title({'CoClassification Matrix','No Partition Hierarchy: Single Community'})
    else
        [ax_C, ax_H] = consensusPlot(ca_mat,cons_vec,Tree_mrcc);
        ax_C.YTick = 1:1:length(ROIlabels);
        ax_C.YTickLabel = ROIlabels(ord);
        ax_C.XTick = 1:1:length(ROIlabels);
        ax_C.XTickLabel = ROIlabels(ord);
        ax_C.XTickLabelRotation = 90;
        
        ax_H.YAxisLocation =  'right';
        ax_H.YLabel.String = [num2str(size(all_part,2)) ' Partitons in Hierarchical Tree (x-axis: meanCA)'];
        ax_H.CurrentPoint
    end
end
end
