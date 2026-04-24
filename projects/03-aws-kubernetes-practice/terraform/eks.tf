# 1. EKSクラスター用のIAMロール
resource "aws_iam_role" "eks_cluster_role" {
  name = "portfolio-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

# ポリシーのアタッチ（EKSの基本機能用）
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 2. ノードグループ用のIAMロール
resource "aws_iam_role" "eks_node_role" {
  name = "portfolio-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# ノードに必要な3つの標準ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_cluster" "main" {
  name     = "portfolio-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # 以前作成したVPCのサブネットを指定
    # 実務ではプライベートサブネットを指定するのが一般的です
    subnet_ids = [module.basic_infrastructure.subnet_public_1_id,module.basic_infrastructure.subnet_public_2_id] 
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "portfolio-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  
  # ノードを配置するサブネット
    subnet_ids = [module.basic_infrastructure.subnet_public_1_id,module.basic_infrastructure.subnet_public_2_id] 

  scaling_config {
    desired_size = 2 # 2台で運用
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"] # EKSは管理用Podが動くため、medium以上を推奨

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
